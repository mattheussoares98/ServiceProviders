-- Enhance service provider invitations table with token and status tracking
ALTER TABLE public.service_provider_invitations
  ADD COLUMN IF NOT EXISTS invite_token VARCHAR(64) NULL,
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE NULL;

-- Add constraint for invitation status
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_sp_invitation_status'
  ) THEN
    ALTER TABLE public.service_provider_invitations
      ADD CONSTRAINT chk_sp_invitation_status
        CHECK (status IN ('pending', 'accepted', 'rejected', 'expired'));
  END IF;
END $$;

-- Create index for quick token lookups
CREATE INDEX IF NOT EXISTS idx_sp_invitations_token
  ON public.service_provider_invitations(invite_token)
  WHERE invite_token IS NOT NULL;

-- Update helper function to support token generation and expiration
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

  -- Insert or update invitation
  INSERT INTO public.service_provider_invitations (
    email,
    service_provider_company_id,
    invite_token,
    status,
    expires_at
  )
  VALUES (
    p_email,
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

  -- Check if user already exists in auth.users
  SELECT id INTO v_auth_user_id FROM auth.users WHERE email = p_email LIMIT 1;

  IF v_auth_user_id IS NOT NULL THEN
    -- User exists, link them directly to provider profiles if not linked
    IF EXISTS (
      SELECT 1 FROM public.service_provider_profiles
      WHERE email = p_email AND service_provider_company_id = p_service_provider_company_id
    ) THEN
      UPDATE public.service_provider_profiles
      SET auth_user_id = v_auth_user_id
      WHERE email = p_email AND service_provider_company_id = p_service_provider_company_id;
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
        p_email,
        p_email,
        true
      );
    END IF;

    -- Mark invitation as accepted
    UPDATE public.service_provider_invitations
    SET accepted_at = now(),
        status = 'accepted'
    WHERE id = v_invitation_id;
  END IF;

  RETURN v_invitation_id;
END;
$$;

-- Trigger to automatically create an invitation upon service provider company creation
CREATE OR REPLACE FUNCTION public.auto_invite_service_provider_company()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.contact_email IS NOT NULL AND LENGTH(TRIM(NEW.contact_email)) > 0 THEN
    PERFORM public.create_service_provider_invitation(
      NEW.contact_email,
      NEW.id,
      gen_random_uuid()::text
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_auto_invite_sp_company ON public.service_provider_companies;
CREATE TRIGGER tr_auto_invite_sp_company
  AFTER INSERT ON public.service_provider_companies
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_invite_service_provider_company();
