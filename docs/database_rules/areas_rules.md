# Areas Table Policies

```sql
CREATE POLICY "Users read own company areas with permission"
  ON public.areas FOR SELECT
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND public.has_permission('locations.read')
    )
    -- Provider mode: read the whole registry of any contracting company that
    -- hired a provider company the user actively belongs to. Wider than the
    -- work-order-scoped grant on assets, because the create form has to browse
    -- the registry before any work order exists.
    OR public.is_provider_of_company(company_id)
  );

CREATE POLICY "Users insert own company areas with permission"
  ON public.areas FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('locations.create')
  );

CREATE POLICY "Users update own company areas with permission"
  ON public.areas FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('locations.update')
  );
```
