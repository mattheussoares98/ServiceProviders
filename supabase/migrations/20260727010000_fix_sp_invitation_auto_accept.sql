-- Fix: remove the auto-accept logic from create_service_provider_invitation.
--
-- Previously, if the invited email already existed in auth.users, the function
-- would immediately mark the invitation as 'accepted'. This caused every new
-- invitation to be auto-accepted because the Edge Function calls
-- inviteUserByEmail AFTER create_service_provider_invitation, which creates
-- the auth user row before the token is even read.
--
-- The correct flow is:
--   1. create_service_provider_invitation → always inserts/refreshes with status='pending'
--   2. Edge Function calls inviteUserByEmail → auth user created
--   3. On actual invite acceptance → handle_service_provider_link trigger fires
--      and sets status='accepted'

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
  v_expires_at := now() + (p_expires_in_days || ' days')::INTERVAL;

  -- Insert or refresh the invitation (always pending)
  -- Auth link happens via trigger on accept, not here.
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

GRANT EXECUTE ON FUNCTION public.create_service_provider_invitation(TEXT, UUID, TEXT, INTEGER) TO authenticated, anon, service_role;
