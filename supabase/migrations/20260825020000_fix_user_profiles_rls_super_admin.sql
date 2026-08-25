-- 1. Update is_admin to recognize super admins
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
AS $$
  SELECT COALESCE(public.is_super_admin(), false) OR COALESCE((SELECT is_admin FROM public.user_profiles WHERE id = auth.uid()), false);
$$;

-- 2. Update has_permission to recognize super admins
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
  IF public.is_super_admin() THEN
    RETURN TRUE;
  END IF;

  SELECT 
    up.is_admin,
    COALESCE(pg.permissions, '[]'::jsonb)
  INTO 
    v_is_admin,
    v_permissions
  FROM public.user_profiles up
  LEFT JOIN public.permission_groups pg ON up.permission_group_id = pg.id
  WHERE up.id = auth.uid();

  IF COALESCE(v_is_admin, false) OR v_permissions ? '*' THEN
    RETURN TRUE;
  END IF;

  RETURN v_permissions ? permission_key;
END;
$$;

-- 3. Fix RLS policies on user_profiles
DROP POLICY IF EXISTS "Users update own company user profiles" ON public.user_profiles;
CREATE POLICY "Users update own company user profiles"
  ON public.user_profiles FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR public.is_super_admin()
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
    OR public.is_super_admin()
  );

DROP POLICY IF EXISTS "Users update own profile" ON public.user_profiles;
CREATE POLICY "Users update own profile"
  ON public.user_profiles FOR UPDATE
  TO authenticated
  USING (
    id = auth.uid()
    OR public.is_super_admin()
  )
  WITH CHECK (
    id = auth.uid()
    OR public.is_super_admin()
  );

DROP POLICY IF EXISTS "Users read own company user profiles" ON public.user_profiles;
CREATE POLICY "Users read own company user profiles"
  ON public.user_profiles FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR public.is_super_admin()
    OR id = auth.uid()
  );

DROP POLICY IF EXISTS "Users insert own company user profiles" ON public.user_profiles;
CREATE POLICY "Users insert own company user profiles"
  ON public.user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    OR public.is_super_admin()
    OR id = auth.uid()
  );

-- 4. Update permission_groups policies for super admins
DROP POLICY IF EXISTS "Users read own company permission groups" ON public.permission_groups;
CREATE POLICY "Users read own company permission groups"
  ON public.permission_groups FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR public.is_super_admin()
  );

DROP POLICY IF EXISTS "Users insert own company permission groups" ON public.permission_groups;
CREATE POLICY "Users insert own company permission groups"
  ON public.permission_groups FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    OR public.is_super_admin()
  );

DROP POLICY IF EXISTS "Users update own company permission groups" ON public.permission_groups;
CREATE POLICY "Users update own company permission groups"
  ON public.permission_groups FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR public.is_super_admin()
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
    OR public.is_super_admin()
  );

DROP POLICY IF EXISTS "Users delete own company permission groups" ON public.permission_groups;
CREATE POLICY "Users delete own company permission groups"
  ON public.permission_groups FOR DELETE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR public.is_super_admin()
  );
