# Work Orders Table Policies

```sql
CREATE POLICY "Users read own company work orders"
  ON public.work_orders FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company work orders"
  ON public.work_orders FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company work orders"
  ON public.work_orders FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
```
