-- Update existing user profiles to match their permission group's admin status
UPDATE public.user_profiles up
SET is_admin = COALESCE(
  (SELECT LOWER(name) = 'administrador' FROM public.permission_groups WHERE id = up.permission_group_id),
  false
);

-- Create or update the trigger function to automate admin status based on the group name
CREATE OR REPLACE FUNCTION public.handle_user_profile_admin_status()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.permission_group_id IS NOT NULL THEN
    NEW.is_admin := COALESCE(
      (SELECT LOWER(name) = 'administrador' FROM public.permission_groups WHERE id = NEW.permission_group_id),
      false
    );
  ELSE
    NEW.is_admin := false;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if it exists
DROP TRIGGER IF EXISTS tr_sync_user_profile_admin_status ON public.user_profiles;

-- Create the trigger to check/update is_admin before any insert or update
CREATE TRIGGER tr_sync_user_profile_admin_status
BEFORE INSERT OR UPDATE ON public.user_profiles
FOR EACH ROW
EXECUTE FUNCTION public.handle_user_profile_admin_status();
