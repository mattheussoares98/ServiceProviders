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

## Realtime Publication

Included in `supabase_realtime` publication with `REPLICA IDENTITY FULL` (migration `20260912230000_publish_change_and_pause_requests_realtime.sql`).

## History

| Migration | Change |
|---|---|
| `20260721215657_create_work_orders.sql` | Table created with RLS policies |
| `20260912230000_publish_change_and_pause_requests_realtime.sql` | Added `public.work_order_change_requests` to `supabase_realtime` publication with `REPLICA IDENTITY FULL` |

