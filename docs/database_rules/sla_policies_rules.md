# SLA Policies Policies

```sql
-- SELECT: company users OR service providers linked to that company
CREATE POLICY "Users read own company sla policies"
  ON public.sla_policies FOR SELECT TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.service_provider_profiles spp
      JOIN public.service_provider_companies spc ON spp.service_provider_company_id = spc.id
      WHERE spp.auth_user_id = auth.uid() AND spc.company_id = public.sla_policies.company_id
    )
  );

-- INSERT: requires sla_policies.create
CREATE POLICY "Company users insert own company sla policies"
  ON public.sla_policies FOR INSERT TO authenticated
  WITH CHECK (company_id = public.get_user_company_id() AND public.has_permission('sla_policies.create'));

-- UPDATE: requires sla_policies.update
CREATE POLICY "Company users update own company sla policies"
  ON public.sla_policies FOR UPDATE TO authenticated
  USING (company_id = public.get_user_company_id() AND public.has_permission('sla_policies.update'));
```

## Triggers

```sql
CREATE TRIGGER tr_prevent_delete_sla_policies
BEFORE DELETE ON public.sla_policies FOR EACH ROW EXECUTE FUNCTION public.prevent_delete();
```

---

## Realtime Publication
Added to `supabase_realtime` publication (`ALTER PUBLICATION supabase_realtime ADD TABLE public.sla_policies;`) to enable granular realtime stream updates on clients.
