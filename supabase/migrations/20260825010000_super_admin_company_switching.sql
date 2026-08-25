-- Function to check if the current authenticated user is a super admin
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth
AS $$
  SELECT COALESCE(
    LOWER(TRIM((SELECT email FROM auth.users WHERE id = auth.uid()))) IN (
      'mattheussbarosa98@gmail.com',
      'mattheussbarbosa@hotmail.com',
      'thiago.saraiva@kephasengenharia.com.br'
    ),
    false
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_super_admin() TO authenticated;

-- Update check_at_least_one_admin trigger function to exempt super admins from the single admin restriction when switching companies
CREATE OR REPLACE FUNCTION public.check_at_least_one_admin()
RETURNS TRIGGER AS $$
BEGIN
  -- Super admins can switch freely between companies without being blocked by the single-admin constraint of the previous company
  IF public.is_super_admin() THEN
    RETURN NULL;
  END IF;

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

-- Update get_pending_invitations to allow super admins to view invitations across companies
CREATE OR REPLACE FUNCTION public.get_pending_invitations(target_company_id UUID)
RETURNS TABLE (
  id UUID,
  email TEXT,
  invited_at TIMESTAMPTZ,
  company_id UUID,
  permission_group_id UUID,
  name TEXT,
  confirmation_sent_at TIMESTAMPTZ
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  -- Validate that the caller has access to the target company (or is super admin)
  IF target_company_id <> public.get_user_company_id() AND NOT public.is_super_admin() THEN
    RAISE EXCEPTION 'Acesso negado para esta empresa.';
  END IF;

  -- Validate that the caller has users.read permission
  IF NOT public.has_permission('users.read') THEN
    RAISE EXCEPTION 'Sem permissão para visualizar convites.';
  END IF;

  RETURN QUERY
  SELECT 
    u.id,
    u.email::TEXT,
    u.invited_at,
    (u.raw_user_meta_data->>'company_id')::UUID,
    (u.raw_user_meta_data->>'permission_group_id')::UUID,
    (u.raw_user_meta_data->>'name')::TEXT,
    u.confirmation_sent_at
  FROM auth.users u
  WHERE 
    (u.raw_user_meta_data->>'company_id')::UUID = target_company_id
    AND u.invited_at IS NOT NULL 
    AND u.confirmed_at IS NULL;
END;
$$;
