# Work Order Change Requests Table Policies

```sql
CREATE POLICY "Users read own company work order change requests"
  ON public.work_order_change_requests FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company work order change requests"
  ON public.work_order_change_requests FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company work order change requests"
  ON public.work_order_change_requests FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
```
