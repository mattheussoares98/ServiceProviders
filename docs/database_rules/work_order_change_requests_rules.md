# Work Order Change Requests Table Policies

```sql
CREATE POLICY "Users read own company work order change requests with permission"
  ON public.work_order_change_requests FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.read')
  );

CREATE POLICY "Users insert own company work order change requests with permission"
  ON public.work_order_change_requests FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.update')
  );

CREATE POLICY "Users update own company work order change requests with permission"
  ON public.work_order_change_requests FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.update')
  );
```
