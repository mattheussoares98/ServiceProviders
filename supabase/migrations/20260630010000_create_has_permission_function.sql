-- Create the has_permission helper function
CREATE OR REPLACE FUNCTION public.has_permission(permission_key TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  v_is_admin BOOLEAN;
  v_permissions JSONB;
BEGIN
  -- Get user profile details
  SELECT 
    up.is_admin,
    COALESCE(pg.permissions, '[]'::jsonb)
  INTO 
    v_is_admin,
    v_permissions
  FROM public.user_profiles up
  LEFT JOIN public.permission_groups pg ON up.permission_group_id = pg.id
  WHERE up.id = auth.uid();

  -- Admin has all permissions
  IF COALESCE(v_is_admin, false) OR v_permissions ? '*' THEN
    RETURN TRUE;
  END IF;

  -- Check if the permission_key exists in the permissions array
  RETURN v_permissions ? permission_key;
END;
$$;

-- Drop old simple policies for locations
DROP POLICY IF EXISTS "Users read own company locations" ON public.locations;
DROP POLICY IF EXISTS "Users insert own company locations" ON public.locations;
DROP POLICY IF EXISTS "Users update own company locations" ON public.locations;

-- Create updated policies integrating the has_permission helper
CREATE POLICY "Users read own company locations with permission"
  ON public.locations FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('locations.read')
  );

CREATE POLICY "Users insert own company locations with permission"
  ON public.locations FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('locations.create')
  );

CREATE POLICY "Users update own company locations with permission"
  ON public.locations FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('locations.update')
  );
