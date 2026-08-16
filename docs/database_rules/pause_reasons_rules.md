# Pause Reasons Policies

```sql
-- SELECT: company users OR service providers linked to that company
CREATE POLICY "Users read own company pause reasons"
  ON public.pause_reasons FOR SELECT TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.service_provider_profiles spp
      JOIN public.service_provider_companies spc ON spp.service_provider_company_id = spc.id
      WHERE spp.auth_user_id = auth.uid() AND spc.company_id = public.pause_reasons.company_id
    )
  );

-- ALL (INSERT/UPDATE/DELETE): company users with work_orders.manage_pending_requests permission
CREATE POLICY "Company users manage own company pause reasons"
  ON public.pause_reasons FOR ALL TO authenticated
  USING (company_id = public.get_user_company_id() AND public.has_permission('work_orders.manage_pending_requests'));
```

## Triggers

```sql
CREATE TRIGGER tr_prevent_delete_pause_reasons
BEFORE DELETE ON public.pause_reasons FOR EACH ROW EXECUTE FUNCTION public.prevent_delete();

-- Blocks soft-delete when active pause requests reference this reason (20260723003600)
CREATE TRIGGER tr_prevent_delete_pause_reasons_with_relations
  BEFORE UPDATE ON public.pause_reasons FOR EACH ROW
  EXECUTE FUNCTION public.check_pause_reason_before_delete();
```
