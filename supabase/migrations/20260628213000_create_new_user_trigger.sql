-- Create trigger function for handling new user profile creation from auth.users metadata
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  company_id_val UUID;
  group_id_val UUID;
  name_val TEXT;
BEGIN
  -- Extract company_id, permission_group_id, and name from user_metadata
  company_id_val := (NEW.raw_user_meta_data->>'company_id')::UUID;
  group_id_val := (NEW.raw_user_meta_data->>'permission_group_id')::UUID;
  name_val := NEW.raw_user_meta_data->>'name';

  -- If company_id is present, create the user profile
  IF company_id_val IS NOT NULL THEN
    INSERT INTO public.user_profiles (
      id, 
      company_id, 
      name, 
      email, 
      permission_group_id, 
      is_active, 
      is_admin, 
      created_at, 
      updated_at
    )
    VALUES (
      NEW.id, 
      company_id_val, 
      COALESCE(name_val, split_part(NEW.email, '@', 1)), 
      NEW.email, 
      group_id_val, 
      true, 
      false, 
      now(), 
      now()
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if it exists
DROP TRIGGER IF EXISTS tr_create_user_profile_on_signup ON auth.users;

-- Create the trigger
CREATE TRIGGER tr_create_user_profile_on_signup
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();
