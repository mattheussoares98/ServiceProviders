-- Migration: 20260926001000_allow_onboarding_users_read_permission_groups.sql
-- Description: Allow users without a company or super admins to read permission groups so onboarding can fetch default groups and assign Administrador.

DROP POLICY IF EXISTS "Users read own company permission groups" ON public.permission_groups;

CREATE POLICY "Users read own company permission groups"
  ON public.permission_groups FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR public.is_super_admin()
    OR public.get_user_company_id() IS NULL
  );
