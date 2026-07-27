-- Remove automatic invitation trigger on service provider company creation
-- This allows service provider companies to be managed locally first without automatically sending email invites
DROP TRIGGER IF EXISTS tr_auto_invite_sp_company ON public.service_provider_companies;
DROP FUNCTION IF EXISTS public.auto_invite_service_provider_company();

-- Create RPC for manually sending/resending service provider invitations
CREATE OR REPLACE FUNCTION public.send_service_provider_invitation(
  p_service_provider_company_id UUID,
  p_email TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_invitation_id UUID;
BEGIN
  -- Re-use create_service_provider_invitation logic
  v_invitation_id := public.create_service_provider_invitation(
    p_email := TRIM(p_email),
    p_service_provider_company_id := p_service_provider_company_id,
    p_invite_token := gen_random_uuid()::text,
    p_expires_in_days := 7
  );

  RETURN v_invitation_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.send_service_provider_invitation(UUID, TEXT) TO authenticated, anon, service_role;

-- Create RPC for revoking/deleting service provider invitations
CREATE OR REPLACE FUNCTION public.delete_service_provider_invitation(
  p_invitation_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  DELETE FROM public.service_provider_invitations
  WHERE id = p_invitation_id;

  RETURN FOUND;
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_service_provider_invitation(UUID) TO authenticated, anon, service_role;

