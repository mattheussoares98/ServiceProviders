-- Fix: service_provider_profiles.is_active should default to false.
--
-- Profiles are created when an invitation is sent (inactive). They only
-- become active after the invited user clicks the email link and sets
-- a password through the accept-invite flow.

ALTER TABLE public.service_provider_profiles
  ALTER COLUMN is_active SET DEFAULT false;

-- Utility function to accept a service provider invitation by email.
-- Called from the Flutter app after the user successfully sets their
-- password via the accept-invite page. Updates both the invitation
-- status and timestamps.
CREATE OR REPLACE FUNCTION public.accept_service_provider_invitation(
  p_email TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.service_provider_invitations
  SET
    status      = 'accepted',
    accepted_at = now()
  WHERE
    email  = p_email
    AND status = 'pending';
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_service_provider_invitation(TEXT)
  TO authenticated, anon, service_role;
