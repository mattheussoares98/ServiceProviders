-- Allow updating user profiles in the same company
CREATE POLICY "Users update own company user profiles"
  ON public.user_profiles FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
