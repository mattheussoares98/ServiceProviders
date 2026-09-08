# checklist_answers — RLS Rules

RLS enabled. Answering a checklist is part of *executing* a work order, so writes are
gated by visibility of the parent work order (which carries the work order read/update
scope) rather than by a `checklists.*` permission key.

## SELECT
```sql
CREATE POLICY "Users read own company checklist answers"
  ON public.checklist_answers FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.service_provider_profiles spp
      JOIN public.service_provider_companies spc ON spp.service_provider_company_id = spc.id
      WHERE spp.auth_user_id = auth.uid() AND spc.company_id = public.checklist_answers.company_id
    )
  );
```

## INSERT
```sql
CREATE POLICY "Users insert own company checklist answers"
  ON public.checklist_answers FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND EXISTS (
      SELECT 1 FROM public.work_orders wo
      WHERE wo.id = public.checklist_answers.work_order_id
    )
  );
```

## UPDATE
```sql
CREATE POLICY "Users update own company checklist answers"
  ON public.checklist_answers FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND EXISTS (
      SELECT 1 FROM public.work_orders wo
      WHERE wo.id = public.checklist_answers.work_order_id
    )
  );
```
The `work_orders` sub-select is itself subject to the `work_orders` SELECT policy, so a
technician scoped to `read_scope = 'assigned'` can only answer checklists on work orders
assigned to them.

## DELETE
No `FOR DELETE` policy. `tr_prevent_delete_checklist_answers` raises on hard delete;
removal is a soft delete via `deleted_at`.

## Provider writes

`20260908160000_allow_providers_to_answer_checklists.sql` added the provider
branch the write policies were missing — until then a provider could read the
checklist of an order it executes but never answer it, and a mandatory item left
it unable to request completion.

`company_id` is no longer taken from the caller. `tr_set_checklist_answer_company`
derives it from the parent work order on INSERT and UPDATE, because the answer's
company is always the order's company, never the writer's — a provider's
`get_user_company_id()` is not the contracting company. It also stops a caller
from writing a row into another tenant.

Both write policies now read:

```sql
(
  company_id = public.get_user_company_id()
  AND EXISTS (SELECT 1 FROM public.work_orders wo WHERE wo.id = work_order_id)
)
OR public.is_provider_member_of_work_order_id(work_order_id)
```

UPDATE also carries this as `WITH CHECK`, which it previously lacked.
