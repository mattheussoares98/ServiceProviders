# Work Orders Table Policies

```sql
CREATE POLICY "Users read own company work orders with permission"
  ON public.work_orders FOR SELECT
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND (
        public.get_work_orders_read_scope() = 'all'
        OR (public.get_work_orders_read_scope() = 'assigned' AND assigned_to_id = auth.uid())
      )
    )
    OR public.is_provider_member_of_work_order(service_provider_company_id, provider_profile_id)
  );

CREATE POLICY "Users insert own company work orders with permission"
  ON public.work_orders FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.create')
    AND created_by_provider_profile_id IS NULL
  );

-- A provider opens the work order as its own provider profile, assigned to its
-- own provider company, under the tenant that hired it.
CREATE POLICY "Providers insert work orders for their companies"
  ON public.work_orders FOR INSERT
  TO authenticated
  WITH CHECK (
    public.is_provider_member_of_work_order(service_provider_company_id, provider_profile_id)
    AND public.is_provider_company_of_company(service_provider_company_id, company_id)
    AND created_by_id IS NULL
    AND public.is_own_provider_profile(created_by_provider_profile_id)
  );

CREATE POLICY "Users update own company work orders with permission"
  ON public.work_orders FOR UPDATE
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND (
        public.get_work_orders_update_scope() = 'all'
        OR (public.get_work_orders_update_scope() = 'assigned' AND assigned_to_id = auth.uid())
        OR (public.get_work_orders_update_scope() = 'own' AND created_by_id = auth.uid())
      )
    )
    OR public.is_provider_member_of_work_order(service_provider_company_id, provider_profile_id)
  )
  WITH CHECK (
    (
      company_id = public.get_user_company_id()
      AND (
        public.get_work_orders_update_scope() = 'all'
        OR (public.get_work_orders_update_scope() = 'assigned' AND assigned_to_id = auth.uid())
        OR (public.get_work_orders_update_scope() = 'own' AND created_by_id = auth.uid())
      )
    )
    OR public.is_provider_member_of_work_order(service_provider_company_id, provider_profile_id)
  );
```
---

## Triggers

### `tr_notify_work_order_assigned`
Fires `AFTER INSERT OR UPDATE OF assigned_to_id, provider_profile_id, service_provider_company_id ON public.work_orders`.
- Resolves recipient user IDs (internal assignee or provider technician/company).
- Calls `public.dispatch_push_notification()` to notify the assigned technician, excluding `auth.uid()`.

---

## Realtime Publication
Added to `supabase_realtime` publication (`ALTER PUBLICATION supabase_realtime ADD TABLE public.work_orders;`) to enable granular realtime stream updates on clients.


