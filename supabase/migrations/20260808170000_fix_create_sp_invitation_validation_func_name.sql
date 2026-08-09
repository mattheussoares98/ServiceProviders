-- Migration: Ensure check_sp_email_availability function exists and fix create_service_provider_invitation call

CREATE OR REPLACE FUNCTION public.check_sp_email_availability(
  p_email TEXT,
  p_service_provider_company_id UUID DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_normalized_email TEXT;
BEGIN
  IF p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 THEN
    RETURN;
  END IF;

  v_normalized_email := LOWER(TRIM(p_email));

  -- 1. Check if email is used as contact_email in another service_provider_company
  IF EXISTS (
    SELECT 1 FROM public.service_provider_companies spc
    WHERE LOWER(TRIM(spc.contact_email)) = v_normalized_email
      AND (p_service_provider_company_id IS NULL OR spc.id != p_service_provider_company_id)
      AND (spc.deleted_at IS NULL)
  ) THEN
    RAISE EXCEPTION 'Este e-mail já está vinculado a outra empresa prestadora de serviços.'
      USING ERRCODE = '23505';
  END IF;

  -- 2. Check if email is used in service_provider_profiles of another service_provider_company
  IF EXISTS (
    SELECT 1 FROM public.service_provider_profiles spp
    WHERE LOWER(TRIM(spp.email)) = v_normalized_email
      AND (p_service_provider_company_id IS NULL OR spp.service_provider_company_id != p_service_provider_company_id)
  ) THEN
    RAISE EXCEPTION 'Este e-mail já está vinculado a outra empresa prestadora de serviços.'
      USING ERRCODE = '23505';
  END IF;

  -- 3. Check if email is in an active/pending invitation for another service_provider_company
  IF EXISTS (
    SELECT 1 FROM public.service_provider_invitations spi
    WHERE LOWER(TRIM(spi.email)) = v_normalized_email
      AND (p_service_provider_company_id IS NULL OR spi.service_provider_company_id != p_service_provider_company_id)
      AND (spi.status = 'pending' OR spi.status = 'accepted')
  ) THEN
    RAISE EXCEPTION 'Este e-mail já está vinculado a outra empresa prestadora de serviços.'
      USING ERRCODE = '23505';
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.check_sp_email_availability(TEXT, UUID) TO authenticated, anon, service_role;

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

  -- Validate email availability using check_sp_email_availability
  PERFORM public.check_sp_email_availability(p_email, p_service_provider_company_id);

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
