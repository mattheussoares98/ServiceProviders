# Service Provider Companies Policies

```sql
-- SELECT: company users (no permission key required for read)
CREATE POLICY "Company users read own service provider companies"
  ON public.service_provider_companies FOR SELECT TO authenticated
  USING (company_id = public.get_user_company_id());

-- SELECT: provider users read their own companies
CREATE POLICY "Provider users read their own provider companies"
  ON public.service_provider_companies FOR SELECT TO authenticated
  USING (public.is_provider_member_of_company(id));

-- INSERT: requires service_providers.create
CREATE POLICY "Company users insert service provider companies"
  ON public.service_provider_companies FOR INSERT TO authenticated
  WITH CHECK (company_id = public.get_user_company_id() AND public.has_permission('service_providers.create'));

-- UPDATE: requires service_providers.update
CREATE POLICY "Company users update service provider companies"
  ON public.service_provider_companies FOR UPDATE TO authenticated
  USING (company_id = public.get_user_company_id() AND public.has_permission('service_providers.update'));
```

## Triggers

```sql
CREATE TRIGGER tr_prevent_delete_service_provider_companies
BEFORE DELETE ON public.service_provider_companies FOR EACH ROW EXECUTE FUNCTION public.prevent_delete();

-- Blocks soft-delete when active work orders exist (20260723003000)
CREATE TRIGGER tr_prevent_delete_service_provider_companies_with_relations
  BEFORE UPDATE ON public.service_provider_companies FOR EACH ROW
  EXECUTE FUNCTION public.check_service_provider_company_before_delete();

-- Auto-invite contact_email on INSERT (20260726210000)
CREATE TRIGGER tr_auto_invite_sp_company
  AFTER INSERT ON public.service_provider_companies FOR EACH ROW
  EXECUTE FUNCTION public.auto_invite_service_provider_company();

-- Validate contact_email uniqueness across SP companies (20260807200000)
CREATE TRIGGER trg_validate_sp_company_contact_email
  BEFORE INSERT OR UPDATE OF contact_email ON public.service_provider_companies FOR EACH ROW
  EXECUTE FUNCTION public.validate_sp_company_contact_email_trg();
```

---

## Realtime Publication
Added to `supabase_realtime` publication (`ALTER PUBLICATION supabase_realtime ADD TABLE public.service_provider_companies;`) to enable granular realtime stream updates on clients.
