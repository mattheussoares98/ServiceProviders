# User Profiles Table Policies

```sql
CREATE POLICY "Users read own company user profiles"
  ON public.user_profiles FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user

CREATE POLICY "Users insert own company user profiles"
  ON public.user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user

CREATE POLICY "Users update own profile"
  ON public.user_profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid());
  //TODO respect the permission group from the user
```
