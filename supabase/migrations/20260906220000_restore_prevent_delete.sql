-- Restore prevent_delete() as an unconditional hard-delete guard.
--
-- 20260630000000_manage_user_invitations.sql redefined the shared prevent_delete()
-- function so it only raised when OLD.id matched a confirmed row in auth.users.
-- That predicate is false for every table except user_profiles, so the trigger
-- became a no-op on assets, work orders, templates, logs, etc. — hard deletes were
-- then blocked only by the absence of a FOR DELETE RLS policy (which silently
-- affects 0 rows instead of raising).
--
-- The user-specific allowance (pending invitations must be deletable, see
-- revoke_invitation()) now lives in its own function bound to user_profiles.

CREATE OR REPLACE FUNCTION public.prevent_delete()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'Hard deletes are disabled. Use soft delete by setting deleted_at instead.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- user_profiles keeps the invitation carve-out: a row whose auth user was never
-- confirmed is a pending invitation and may be hard-deleted (revoke_invitation
-- deletes from auth.users, which cascades here).
CREATE OR REPLACE FUNCTION public.prevent_user_profile_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = OLD.id AND confirmed_at IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'Hard deletes are disabled. Use soft delete by setting deleted_at instead.';
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_prevent_delete_user_profiles ON public.user_profiles;
CREATE TRIGGER tr_prevent_delete_user_profiles
BEFORE DELETE ON public.user_profiles
FOR EACH ROW
EXECUTE FUNCTION public.prevent_user_profile_delete();
