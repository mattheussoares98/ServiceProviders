# Categories Table Policies

```sql
CREATE POLICY "Users read own company categories"
  ON public.categories FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company categories"
  ON public.categories FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company categories"
  ON public.categories FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
```
