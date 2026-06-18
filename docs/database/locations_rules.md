# Locations Table Policies

```sql
CREATE POLICY "Users read own company locations"
  ON public.locations FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company locations"
  ON public.locations FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company locations"
  ON public.locations FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
```
