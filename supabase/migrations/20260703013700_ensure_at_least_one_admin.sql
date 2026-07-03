-- Create or replace trigger function to ensure every company has at least one active admin
CREATE OR REPLACE FUNCTION public.check_at_least_one_admin()
RETURNS TRIGGER AS $$
BEGIN
  -- If we are updating an active admin to something that is not an active admin, or if we delete
  IF (TG_OP = 'DELETE' AND OLD.is_admin = true AND OLD.is_active = true AND OLD.deleted_at IS NULL) OR
     (TG_OP = 'UPDATE' AND (OLD.is_admin = true AND OLD.is_active = true AND OLD.deleted_at IS NULL) AND
      (NEW.is_admin = false OR NEW.is_active = false OR NEW.deleted_at IS NOT NULL OR NEW.company_id != OLD.company_id)) THEN
    
    -- Check if there are any remaining active admins for this company in the table
    IF NOT EXISTS (
      SELECT 1 
      FROM public.user_profiles 
      WHERE company_id = OLD.company_id 
        AND is_admin = true 
        AND is_active = true 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível remover o único usuário administrador ativo da empresa.';
    END IF;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if it exists
DROP TRIGGER IF EXISTS tr_check_at_least_one_admin ON public.user_profiles;

-- Create the trigger to execute AFTER UPDATE OR DELETE
CREATE TRIGGER tr_check_at_least_one_admin
  AFTER UPDATE OR DELETE ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.check_at_least_one_admin();
