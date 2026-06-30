# Assets Table Policies

```sql
CREATE POLICY "Users read own company assets with permission"
  ON public.assets FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('assets.read')
  );

CREATE POLICY "Users insert own company assets with permission"
  ON public.assets FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('assets.create')
  );

CREATE POLICY "Users update own company assets with permission"
  ON public.assets FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('assets.update')
  );
```
