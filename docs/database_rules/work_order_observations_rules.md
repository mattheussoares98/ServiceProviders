# Work Order Observations Table Policies

```sql
-- SELECT: company users or assigned provider members
CREATE POLICY "Users can view observations of their company"
  ON public.work_order_observations FOR SELECT
  USING (
    company_id = public.get_user_company_id()
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );

-- INSERT: an internal employee writes as themselves; a provider writes as their
-- own provider profile and may not borrow an internal author_id
CREATE POLICY "Users can insert observations into work orders of their company"
  ON public.work_order_observations FOR INSERT
  WITH CHECK (
    (
      company_id = public.get_user_company_id()
      AND author_provider_profile_id IS NULL
      AND (author_id = auth.uid() OR public.has_permission('work_orders.update'))
    )
    OR (
      public.is_provider_member_of_work_order_id(work_order_id)
      AND author_id IS NULL
      AND public.is_own_provider_profile(author_provider_profile_id)
    )
  );

-- UPDATE: author OR approver (company), or author (provider)
CREATE POLICY "Users can update observations of their company"
  ON public.work_order_observations FOR UPDATE
  USING (
    (
      company_id = public.get_user_company_id()
      AND (
        author_id = auth.uid()
        OR public.has_permission('work_orders.delete_observation')
        OR public.has_permission('work_orders.update')
      )
    )
    OR (
      public.is_provider_member_of_work_order_id(work_order_id)
      AND public.is_own_provider_profile(author_provider_profile_id)
    )
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );
```

## Helper Functions

| Function | Purpose |
|---|---|
| `public.is_own_provider_profile(UUID)` | True when the service provider profile belongs to `auth.uid()` and is active. Keeps a provider from authoring as a colleague. |

> **Note:** `work_order_observations` uses actual SQL DELETE (for soft delete via `deleted_at`) controlled by the UPDATE policy. No hard-delete trigger is applied — the DELETE RLS policy from the original migration was removed in `20260811020000_fix_work_order_observations_rls.sql`.

## Triggers

```sql
-- Push notification trigger for newly added observations
CREATE TRIGGER tr_notify_observation
AFTER INSERT ON public.work_order_observations
FOR EACH ROW EXECUTE FUNCTION public.handle_notify_observation();
```

## History

| Migration | Change |
|---|---|
| `20260725120000_create_work_order_observations.sql` | Table created with initial RLS (SELECT filtered by `deleted_at IS NULL`, DELETE policy for author/approver) |
| `20260811020000_fix_work_order_observations_rls.sql` | RLS rewritten: SELECT removed `deleted_at` filter; INSERT expanded to allow users with `work_orders.update`; DELETE removed; UPDATE expanded with `WITH CHECK` |
| `20260820120000_add_provider_access_to_work_orders.sql` | Provider branches added to SELECT / INSERT / UPDATE |
| `20260820140000_allow_provider_authored_observations.sql` | `author_id` made nullable, `author_provider_profile_id` added with a single-author CHECK; INSERT/UPDATE rewritten around `is_own_provider_profile` |
| `20260822160000_add_push_notification_triggers.sql` | Added `tr_notify_observation` trigger to dispatch notifications for new observations |

