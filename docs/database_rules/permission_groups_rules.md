# Permission Groups Table Policies

```sql
CREATE POLICY "Users read own company permission groups"
  ON public.permission_groups FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user

CREATE POLICY "Users insert own company permission groups"
  ON public.permission_groups FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user

CREATE POLICY "Users update own company permission groups"
  ON public.permission_groups FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user

CREATE POLICY "Users delete own company permission groups"
  ON public.permission_groups FOR DELETE
  TO authenticated
  USING (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user
```
