-- Migration: Validate email uniqueness across service provider companies and profiles
-- Prevents a single email from being associated with multiple service provider companies (either as contact_email or profile email).

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

-- Trigger function for service_provider_profiles
CREATE OR REPLACE FUNCTION public.validate_sp_profile_email_trg()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM public.check_sp_email_availability(NEW.email, NEW.service_provider_company_id);
  RETURN NEW;
END;
$$;

-- Drop trigger if exists and recreate on service_provider_profiles
DROP TRIGGER IF EXISTS trg_validate_sp_profile_email ON public.service_provider_profiles;
CREATE TRIGGER trg_validate_sp_profile_email
  BEFORE INSERT OR UPDATE OF email, service_provider_company_id
  ON public.service_provider_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_sp_profile_email_trg();

-- Trigger function for service_provider_companies contact_email
CREATE OR REPLACE FUNCTION public.validate_sp_company_contact_email_trg()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.contact_email IS NOT NULL AND LENGTH(TRIM(NEW.contact_email)) > 0 THEN
    PERFORM public.check_sp_email_availability(NEW.contact_email, NEW.id);
  END IF;
  RETURN NEW;
END;
$$;

-- Drop trigger if exists and recreate on service_provider_companies
DROP TRIGGER IF EXISTS trg_validate_sp_company_contact_email ON public.service_provider_companies;
CREATE TRIGGER trg_validate_sp_company_contact_email
  BEFORE INSERT OR UPDATE OF contact_email
  ON public.service_provider_companies
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_sp_company_contact_email_trg();

-- Update create_service_provider_invitation to run validation check first
CREATE OR REPLACE FUNCTION public.create_service_provider_invitation(
  p_email TEXT,
  p_service_provider_company_id UUID,
  p_invite_token TEXT DEFAULT NULL,
  p_expires_in_days INTEGER DEFAULT 7
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_invitation_id UUID;
  v_expires_at TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Validate email availability before creating/refreshing invitation
  PERFORM public.check_sp_email_availability(p_email, p_service_provider_company_id);

  v_expires_at := now() + (p_expires_in_days || ' days')::INTERVAL;

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
    SET created_at   = now(),
        invite_token = COALESCE(EXCLUDED.invite_token, service_provider_invitations.invite_token),
        status       = 'pending',
        expires_at   = v_expires_at
  RETURNING id INTO v_invitation_id;

  RETURN v_invitation_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.check_sp_email_availability(TEXT, UUID) TO authenticated, anon, service_role;
