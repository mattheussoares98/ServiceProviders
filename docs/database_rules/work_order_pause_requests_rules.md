# Work Order Pause Requests Table Policies

## RLS Policies

```sql
-- SELECT: company users OR service providers linked to the work order
CREATE POLICY "Users read own company work order pause requests"
  ON public.work_order_pause_requests FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      JOIN public.service_provider_profiles spp ON wo.service_provider_company_id = spp.service_provider_company_id
      WHERE wo.id = work_order_id AND spp.auth_user_id = auth.uid()
    )
  );

-- INSERT: requester must be the caller; allowed if company user with permission OR SP linked to WO
CREATE POLICY "Users insert work order pause requests"
  ON public.work_order_pause_requests FOR INSERT
  TO authenticated
  WITH CHECK (
    requested_by_id = auth.uid()
    AND (
      (
        company_id = public.get_user_company_id()
        AND public.has_permission('work_orders.change_status')
      )
      OR EXISTS (
        SELECT 1 FROM public.work_orders wo
        JOIN public.service_provider_profiles spp ON wo.service_provider_company_id = spp.service_provider_company_id
        WHERE wo.id = work_order_id AND spp.auth_user_id = auth.uid()
      )
    )
  );

-- UPDATE: approver (has permission) OR original requester on pending requests OR SP linked to pending WO
-- Added in migration 20260812220000_add_resumed_by_to_pause_requests.sql (replaces original policy)
CREATE POLICY "Users update work order pause requests"
  ON public.work_order_pause_requests FOR UPDATE
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND public.has_permission('work_orders.approve_pause')
    )
    OR (
      requested_by_id = auth.uid()
      AND status = 'pending'
    )
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      JOIN public.service_provider_profiles spp ON wo.service_provider_company_id = spp.service_provider_company_id
      WHERE wo.id = work_order_id AND spp.auth_user_id = auth.uid()
      AND status = 'pending'
    )
  );
```

## Triggers

```sql
-- Hard delete prevention (no soft-delete column on this table)
CREATE TRIGGER tr_prevent_delete_pause_requests
BEFORE DELETE ON public.work_order_pause_requests
FOR EACH ROW EXECUTE FUNCTION public.prevent_delete();
```

## History

| Migration | Change |
|---|---|
| `20260721210000_create_sla_and_pauses.sql` | Table created with base columns (`reason`, `sector` as plain text) |
| `20260721220000_add_pause_reasons.sql` | `reason` renamed to `custom_reason` (nullable); `reason_id` FK added |
| `20260721230000_create_sectors.sql` | `sector` column dropped; `sector_id` FK added |
| `20260725210000_add_work_order_completion_metadata.sql` | `event_type` column added (default `'pause'`) |
| `20260812220000_add_resumed_by_to_pause_requests.sql` | `resumed_by_id` FK added; UPDATE policy expanded to allow SP users to update pending requests |
