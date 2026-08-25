# Assets Table Policies

```sql
CREATE POLICY "Users read own company assets with permission"
  ON public.assets FOR SELECT
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND public.has_permission('assets.read')
    )
    -- Provider mode: read only the rows referenced by the work orders assigned
    -- to a provider company the user actively belongs to.
    OR public.is_provider_referenced_asset(id)
  );

CREATE POLICY "Users insert own company assets with permission"
  ON public.assets FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('assets.create')
  );

CREATE POLICY "Users update own company assets with permission"
  ON public.assets FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('assets.update')
  );
```

---

## Realtime Publication
Added to `supabase_realtime` publication (`ALTER PUBLICATION supabase_realtime ADD TABLE public.assets;`) to enable granular realtime stream updates on clients.
