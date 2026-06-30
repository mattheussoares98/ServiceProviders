# Work Orders Table Policies

```sql
CREATE POLICY "Users read own company work orders with permission"
  ON public.work_orders FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.read')
  );

CREATE POLICY "Users insert own company work orders with permission"
  ON public.work_orders FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.create')
  );

CREATE POLICY "Users update own company work orders with permission"
  ON public.work_orders FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.update')
  );
```
