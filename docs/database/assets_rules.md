# Assets Table Policies

```sql
CREATE POLICY "Users read own company assets"
  ON public.assets FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company assets"
  ON public.assets FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company assets"
  ON public.assets FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
```
