# Database Global Rules & Security

This document details the global rules, Row Level Security (RLS) helpers, and soft‑delete infrastructure configured on the remote Supabase (PostgreSQL) database.

---

## 1. Row Level Security (RLS) Helpers

### Multi‑Tenant Context Helper

```sql
CREATE OR REPLACE FUNCTION public.get_user_company_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT company_id FROM public.user_profiles WHERE id = auth.uid();
$$;
```

### Admin Context Helper

```sql
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT COALESCE(is_admin, false) FROM public.user_profiles WHERE id = auth.uid();
$$;
```

### Provider Work Order Membership Helpers

```sql
CREATE OR REPLACE FUNCTION public.is_provider_member_of_work_order(
  p_service_provider_company_id UUID,
  p_provider_profile_id UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.service_provider_profiles spp
    WHERE spp.auth_user_id = auth.uid()
      AND spp.service_provider_company_id = p_service_provider_company_id
      AND spp.is_active
      AND (p_provider_profile_id IS NULL OR p_provider_profile_id = spp.id)
  );
$$;

CREATE OR REPLACE FUNCTION public.is_provider_member_of_work_order_id(p_work_order_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.work_orders wo
    JOIN public.service_provider_profiles spp
      ON spp.service_provider_company_id = wo.service_provider_company_id
    WHERE wo.id = p_work_order_id
      AND spp.auth_user_id = auth.uid()
      AND spp.is_active
      AND (wo.provider_profile_id IS NULL OR wo.provider_profile_id = spp.id)
  );
$$;

CREATE OR REPLACE FUNCTION public.is_provider_member_of_company(p_service_provider_company_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.service_provider_profiles spp
    WHERE spp.service_provider_company_id = p_service_provider_company_id
      AND spp.auth_user_id = auth.uid()
      AND spp.is_active
  );
$$;
```

---

## 2. Soft Delete Policy

Any table that contains a `deleted_at` column is restricted from hard deletion. Instead of a `DELETE` query, clients must perform an `UPDATE` setting `deleted_at` to the current timestamp.

### Hard Delete Prevention Trigger

```sql
CREATE OR REPLACE FUNCTION public.prevent_delete()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'Hard deletes are disabled. Use soft delete by setting deleted_at instead.';
END;
$$ LANGUAGE plpgsql;
```

### Applied Tables (soft‑delete enabled)
- **companies** (`tr_prevent_delete_companies`)
- **user_profiles** (`tr_prevent_delete_user_profiles`)
- **locations** (`tr_prevent_delete_locations`)
- **areas** (`tr_prevent_delete_areas`)
- **assets** (`tr_prevent_delete_assets`)
- **categories** (`tr_prevent_delete_categories`)
- **attachments** (`tr_prevent_delete_attachments`)
- **work_orders** (`tr_prevent_delete_work_orders`)
- **work_order_change_requests** (`tr_prevent_delete_work_order_change_requests`)

---

## 3. Per‑Table RLS Policies

Table‑specific policies are maintained in individual files within this directory:
- [companies_rules.md](companies_rules.md)
- [permission_groups_rules.md](permission_groups_rules.md)
- [user_profiles_rules.md](user_profiles_rules.md)
- [locations_rules.md](locations_rules.md)
- [areas_rules.md](areas_rules.md)
- [assets_rules.md](assets_rules.md)
- [categories_rules.md](categories_rules.md)
- [work_orders_rules.md](work_orders_rules.md)
- [work_order_change_requests_rules.md](work_order_change_requests_rules.md)
- [work_order_pause_requests_rules.md](work_order_pause_requests_rules.md)
- [work_order_observations_rules.md](work_order_observations_rules.md)
- [attachments_rules.md](attachments_rules.md)
- [sla_policies_rules.md](sla_policies_rules.md)
- [pause_reasons_rules.md](pause_reasons_rules.md)
- [sectors_rules.md](sectors_rules.md)
- [service_provider_companies_rules.md](service_provider_companies_rules.md)
- [service_provider_profiles_rules.md](service_provider_profiles_rules.md)
- [service_provider_invitations_rules.md](service_provider_invitations_rules.md)
- [user_configurations_rules.md](user_configurations_rules.md)
- [user_device_tokens_rules.md](user_device_tokens_rules.md)
- [sync_errors_rules.md](sync_errors_rules.md)
- [work_order_history_rules.md](work_order_history_rules.md)

---

## 4. Safe Deletion & Reference Checks

For tables that do not support soft delete (e.g., `permission_groups`), hard deletion is permitted but guarded by reference checks. See the dedicated [permission_groups_rules.md](permission_groups_rules.md) file for the constraint implementation.

---

## 5. Default Password for Invited Users

When inviting new users via the `invite-user` Edge Function:
* Immediately after invoking `inviteUserByEmail`, the function calls `admin.updateUserById` to set their initial password to `'123456'`.
* This ensures that when the user taps their email confirmation/invitation link, their password is already preset, avoiding the need to choose a password from scratch.

---

## 6. Push Notification Dispatch Trigger Infrastructure

A shared security-definer helper `public.dispatch_push_notification(p_user_ids UUID[], p_title TEXT, p_body TEXT, p_data JSONB)` filters out the triggering actor (`auth.uid()`), ignores nulls/duplicates, and calls the `send-push-notification` Edge Function asynchronously via `net.http_post`.
Triggers are attached to:
- `work_orders`: assignment and reassignment notifications
- `work_order_pause_requests`: pause and completion creation and evaluation notifications
- `work_order_observations`: new observation notifications



