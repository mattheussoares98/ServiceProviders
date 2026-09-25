-- Migration: 20260925234500_allow_onboarding_users_read_company.sql
-- Description: Allow authenticated users who do not yet belong to any company (or super admins) to read companies, enabling PostgREST insert().select() and onboarding company verification.

DROP POLICY IF EXISTS "Users read own company" ON public.companies;

CREATE POLICY "Users read own company"
  ON public.companies FOR SELECT
  TO authenticated
  USING (
    id = public.get_user_company_id()
    OR public.is_admin()
    OR public.is_super_admin()
    OR public.get_user_company_id() IS NULL
  );
