# Areas Table Policies

```sql
CREATE POLICY "Users read own company areas"
  ON public.areas FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company areas"
  ON public.areas FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company areas"
  ON public.areas FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
```
