-- Migration: Add invitation_status to service_provider_companies and sync with invitations

ALTER TABLE public.service_provider_companies
  ADD COLUMN IF NOT EXISTS invitation_status VARCHAR(20) NULL;

-- Constraint for invitation_status column
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_sp_company_invitation_status'
  ) THEN
    ALTER TABLE public.service_provider_companies
      ADD CONSTRAINT chk_sp_company_invitation_status
        CHECK (invitation_status IN ('pending', 'accepted', 'rejected', 'expired'));
  END IF;
END $$;

-- Backfill invitation_status from existing service_provider_invitations
UPDATE public.service_provider_companies spc
SET invitation_status = spi.status
FROM public.service_provider_invitations spi
WHERE spi.service_provider_company_id = spc.id;

-- Update create_service_provider_invitation to update service_provider_companies.invitation_status
CREATE OR REPLACE FUNCTION public.create_service_provider_invitation(
  p_email TEXT,
  p_service_provider_company_id UUID,
  p_invite_token TEXT DEFAULT NULL,
  p_expires_in_days INT DEFAULT 7
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_invitation_id UUID;
  v_auth_user_id UUID;
  v_expires_at TIMESTAMP WITH TIME ZONE;
BEGIN
  v_expires_at := now() + (p_expires_in_days || ' days')::INTERVAL;

  -- Validate email availability before creating/refreshing invitation
  PERFORM public.validate_sp_email_uniqueness(p_email, p_service_provider_company_id);

  -- Insert or update invitation
  INSERT INTO public.service_provider_invitations (
    email,
    service_provider_company_id,
    invite_token,
    status,
    expires_at
  )
  VALUES (
    TRIM(p_email),
    p_service_provider_company_id,
    COALESCE(p_invite_token, gen_random_uuid()::text),
    'pending',
    v_expires_at
  )
  ON CONFLICT (email, service_provider_company_id) DO UPDATE
    SET created_at = now(),
        invite_token = COALESCE(EXCLUDED.invite_token, service_provider_invitations.invite_token),
        status = 'pending',
        expires_at = v_expires_at
  RETURNING id INTO v_invitation_id;

  -- Sync status on service_provider_companies
  UPDATE public.service_provider_companies
  SET invitation_status = 'pending'
  WHERE id = p_service_provider_company_id;

  -- Check if user already exists in auth.users
  SELECT id INTO v_auth_user_id FROM auth.users WHERE email = TRIM(p_email) LIMIT 1;

  IF v_auth_user_id IS NOT NULL THEN
    -- User exists, link them directly to provider profiles if not linked
    IF EXISTS (
      SELECT 1 FROM public.service_provider_profiles
      WHERE email = TRIM(p_email) AND service_provider_company_id = p_service_provider_company_id
    ) THEN
      UPDATE public.service_provider_profiles
      SET auth_user_id = v_auth_user_id
      WHERE email = TRIM(p_email) AND service_provider_company_id = p_service_provider_company_id;
    ELSE
      INSERT INTO public.service_provider_profiles (
        auth_user_id,
        service_provider_company_id,
        name,
        email,
        is_active
      )
      VALUES (
        v_auth_user_id,
        p_service_provider_company_id,
        TRIM(p_email),
        TRIM(p_email),
        true
      );
    END IF;

    -- Mark invitation as accepted and sync company status
    UPDATE public.service_provider_invitations
    SET accepted_at = now(),
        status = 'accepted'
    WHERE id = v_invitation_id;

    UPDATE public.service_provider_companies
    SET invitation_status = 'accepted'
    WHERE id = p_service_provider_company_id;
  END IF;

  RETURN v_invitation_id;
END;
$$;

-- Update accept_service_provider_invitation function to sync company status
CREATE OR REPLACE FUNCTION public.accept_service_provider_invitation(
  p_email TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_company_id UUID;
BEGIN
  -- Get matching company ID for pending invitation
  SELECT service_provider_company_id INTO v_company_id
  FROM public.service_provider_invitations
  WHERE email = TRIM(p_email) AND status = 'pending'
  LIMIT 1;

  UPDATE public.service_provider_invitations
  SET
    status      = 'accepted',
    accepted_at = now()
  WHERE
    email  = TRIM(p_email)
    AND status = 'pending';

  IF v_company_id IS NOT NULL THEN
    UPDATE public.service_provider_companies
    SET invitation_status = 'accepted'
    WHERE id = v_company_id;
  END IF;
END;
$$;

-- Update delete_service_provider_invitation to clear invitation_status if deleted
CREATE OR REPLACE FUNCTION public.delete_service_provider_invitation(
  p_invitation_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_company_id UUID;
  v_latest_status VARCHAR(20);
BEGIN
  SELECT service_provider_company_id INTO v_company_id
  FROM public.service_provider_invitations
  WHERE id = p_invitation_id;

  DELETE FROM public.service_provider_invitations
  WHERE id = p_invitation_id;

  IF v_company_id IS NOT NULL THEN
    SELECT status INTO v_latest_status
    FROM public.service_provider_invitations
    WHERE service_provider_company_id = v_company_id
    ORDER BY created_at DESC
    LIMIT 1;

    UPDATE public.service_provider_companies
    SET invitation_status = v_latest_status
    WHERE id = v_company_id;
  END IF;

  RETURN FOUND;
END;
$$;
