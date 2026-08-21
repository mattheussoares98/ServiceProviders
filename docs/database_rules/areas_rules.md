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
    -- Provider mode: read only the rows referenced by the work orders assigned
    -- to a provider company the user actively belongs to.
    OR public.is_provider_referenced_area(id)
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
