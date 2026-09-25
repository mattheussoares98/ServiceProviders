-- Migration: 20260925233000_allow_onboarding_users_insert_company.sql
-- Description: Allow authenticated users who do not yet belong to any company (or super admins) to insert a new company.

DROP POLICY IF EXISTS "Admins can insert companies" ON public.companies;

CREATE POLICY "Authenticated users without company can insert"
  ON public.companies FOR INSERT
  TO authenticated
  WITH CHECK (
    public.is_super_admin() 
    OR public.get_user_company_id() IS NULL
  );
