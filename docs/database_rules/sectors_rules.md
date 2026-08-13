# Sectors Policies

```sql
-- SELECT: company users OR service providers linked to that company
CREATE POLICY "Users read own company sectors"
  ON public.sectors FOR SELECT TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.service_provider_profiles spp
      JOIN public.service_provider_companies spc ON spp.service_provider_company_id = spc.id
      WHERE spp.auth_user_id = auth.uid() AND spc.company_id = public.sectors.company_id
    )
  );

-- INSERT: requires sectors.create
CREATE POLICY "Company users insert own company sectors with permission"
  ON public.sectors FOR INSERT TO authenticated
  WITH CHECK (company_id = public.get_user_company_id() AND public.has_permission('sectors.create'));

-- UPDATE: requires sectors.update
CREATE POLICY "Company users update own company sectors with permission"
  ON public.sectors FOR UPDATE TO authenticated
  USING (company_id = public.get_user_company_id() AND public.has_permission('sectors.update'));
```

## Triggers

```sql
CREATE TRIGGER tr_prevent_delete_sectors
BEFORE DELETE ON public.sectors FOR EACH ROW EXECUTE FUNCTION public.prevent_delete();

-- Blocks soft-delete when active pause requests reference this sector (20260721230000)
CREATE TRIGGER tr_prevent_delete_sectors_with_relations
  BEFORE UPDATE ON public.sectors FOR EACH ROW
  EXECUTE FUNCTION public.check_sector_before_delete();
```
