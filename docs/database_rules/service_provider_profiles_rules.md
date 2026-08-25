# Service Provider Profiles Policies

```sql
-- SELECT: company users owning the SP company OR the SP user reading their own profile
CREATE POLICY "Company users read provider profiles of their companies"
  ON public.service_provider_profiles FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.service_provider_companies spc
      WHERE spc.id = service_provider_company_id AND spc.company_id = public.get_user_company_id())
  );

CREATE POLICY "Provider users read their own profile"
  ON public.service_provider_profiles FOR SELECT TO authenticated
  USING (auth_user_id = auth.uid());

-- INSERT: requires service_providers.create + ownership of SP company
CREATE POLICY "Company users insert provider profiles"
  ON public.service_provider_profiles FOR INSERT TO authenticated
  WITH CHECK (
    public.has_permission('service_providers.create')
    AND EXISTS (SELECT 1 FROM public.service_provider_companies spc
      WHERE spc.id = service_provider_company_id AND spc.company_id = public.get_user_company_id())
  );

-- UPDATE: requires service_providers.update + ownership of SP company
CREATE POLICY "Company users update provider profiles"
  ON public.service_provider_profiles FOR UPDATE TO authenticated
  USING (
    public.has_permission('service_providers.update')
    AND EXISTS (SELECT 1 FROM public.service_provider_companies spc
      WHERE spc.id = service_provider_company_id AND spc.company_id = public.get_user_company_id())
  );
```

## Triggers

```sql
CREATE TRIGGER tr_prevent_delete_service_provider_profiles
BEFORE DELETE ON public.service_provider_profiles FOR EACH ROW EXECUTE FUNCTION public.prevent_delete();

-- Validate email uniqueness across SP companies on INSERT/UPDATE (20260807200000)
CREATE TRIGGER trg_validate_sp_profile_email
  BEFORE INSERT OR UPDATE OF email, service_provider_company_id
  ON public.service_provider_profiles FOR EACH ROW
  EXECUTE FUNCTION public.validate_sp_profile_email_trg();
```

---

## Realtime Publication
Added to `supabase_realtime` publication (`ALTER PUBLICATION supabase_realtime ADD TABLE public.service_provider_profiles;`) to enable granular realtime stream updates on clients.
