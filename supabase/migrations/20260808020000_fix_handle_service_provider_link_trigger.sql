-- Fix: handle_service_provider_link should NOT activate the profile or mark the
-- invitation as accepted when auth.users is created.
--
-- The trigger fires when Supabase creates the auth.users row during
-- inviteUserByEmail. At that point the user has NOT yet seen the invite link,
-- let alone set a password. Prematurely setting is_active = true and
-- accepted_at = now() made the /accept-invite page display "Convite aceito!"
-- immediately instead of showing the name/password form.
--
-- Correct responsibility split:
--   Trigger (here)     → link auth_user_id to the pending profile; keep is_active = false.
--   AcceptInviteCubit  → after user submits name + password, set is_active = true
--                         and call accept_service_provider_invitation() to mark the
--                         invitation status = 'accepted' / accepted_at = now().

CREATE OR REPLACE FUNCTION public.handle_service_provider_link()
RETURNS TRIGGER AS $$
DECLARE
  v_invitation RECORD;
BEGIN
  -- Find every pending invitation for this email
  FOR v_invitation IN
    SELECT * FROM public.service_provider_invitations
    WHERE email = NEW.email
      AND accepted_at IS NULL
  LOOP
    IF EXISTS (
      SELECT 1 FROM public.service_provider_profiles
      WHERE email = NEW.email
        AND service_provider_company_id = v_invitation.service_provider_company_id
    ) THEN
      -- Profile already exists (e.g. created via createServiceProviderProfile) —
      -- just link the auth user id so the cubit can fetch it.
      UPDATE public.service_provider_profiles
         SET auth_user_id = NEW.id
       WHERE email = NEW.email
         AND service_provider_company_id = v_invitation.service_provider_company_id;
    ELSE
      -- Create the profile in INACTIVE state.
      -- The user must go through /accept-invite to activate it.
      INSERT INTO public.service_provider_profiles (
        auth_user_id,
        service_provider_company_id,
        name,
        email,
        is_active
      )
      VALUES (
        NEW.id,
        v_invitation.service_provider_company_id,
        COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
        NEW.email,
        false   -- ← inactive until user submits the accept-invite form
      );
    END IF;

    -- Do NOT mark accepted_at or status here.
    -- Acceptance is handled by accept_service_provider_invitation() called
    -- from AcceptInviteCubit after the user sets their password.
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
