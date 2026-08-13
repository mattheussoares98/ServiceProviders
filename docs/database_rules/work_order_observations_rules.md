# Work Order Observations Table Policies

```sql
-- SELECT: company users (no permission key, all members can view)
CREATE POLICY "Users can view observations of their company"
  ON public.work_order_observations FOR SELECT TO authenticated
  USING (company_id = public.get_user_company_id());

-- INSERT: must be author OR have work_orders.update permission
CREATE POLICY "Users can insert observations into work orders of their company"
  ON public.work_order_observations FOR INSERT TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND (author_id = auth.uid() OR public.has_permission('work_orders.update'))
  );

-- UPDATE: author OR approver (work_orders.delete_observation / work_orders.update)
CREATE POLICY "Users can update observations of their company"
  ON public.work_order_observations FOR UPDATE TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND (
      author_id = auth.uid()
      OR public.has_permission('work_orders.delete_observation')
      OR public.has_permission('work_orders.update')
    )
  )
  WITH CHECK (company_id = public.get_user_company_id());
```

> **Note:** `work_order_observations` uses actual SQL DELETE (for soft delete via `deleted_at`) controlled by the UPDATE policy. No hard-delete trigger is applied — the DELETE RLS policy from the original migration was removed in `20260811020000_fix_work_order_observations_rls.sql`.

## History

| Migration | Change |
|---|---|
| `20260725120000_create_work_order_observations.sql` | Table created with initial RLS (SELECT filtered by `deleted_at IS NULL`, DELETE policy for author/approver) |
| `20260811020000_fix_work_order_observations_rls.sql` | RLS rewritten: SELECT removed `deleted_at` filter; INSERT expanded to allow users with `work_orders.update`; DELETE removed; UPDATE expanded with `WITH CHECK` |
