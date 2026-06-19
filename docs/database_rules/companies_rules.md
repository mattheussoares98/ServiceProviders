# Companies Table Policies

```sql
CREATE POLICY "Users read own company"
  ON public.companies FOR SELECT
  TO authenticated
  USING (id = public.get_user_company_id() OR public.is_admin());

CREATE POLICY "Admins can insert companies"
  ON public.companies FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

CREATE POLICY "Users update own company"
  ON public.companies FOR UPDATE
  TO authenticated
  USING (id = public.get_user_company_id() OR public.is_admin());
```
