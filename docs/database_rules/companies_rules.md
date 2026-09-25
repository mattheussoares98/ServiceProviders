# Companies Table Policies

```sql
CREATE POLICY "Users read own company"
  ON public.companies FOR SELECT
  TO authenticated
  USING (id = public.get_user_company_id() OR public.is_admin());

CREATE POLICY "Authenticated users without company can insert"
  ON public.companies FOR INSERT
  TO authenticated
  WITH CHECK (public.is_super_admin() OR public.get_user_company_id() IS NULL);

CREATE POLICY "Users update own company"
  ON public.companies FOR UPDATE
  TO authenticated
  USING (id = public.get_user_company_id() OR public.is_admin());
```

## Business Rules & Triggers

- `tr_enforce_company_work_type_transition` (`BEFORE UPDATE`):
  Enforces upgrade-only transitions for `work_type`. Allowed:
  - `internal_only` -> `hybrid`
  - `service_provider_only` -> `hybrid`
  Any other change (such as downgrading from `hybrid` or transitioning between single modes) raises a pt-BR exception.

