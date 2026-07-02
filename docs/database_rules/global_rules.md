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

---

## 4. Safe Deletion & Reference Checks

For tables that do not support soft delete (e.g., `permission_groups`), hard deletion is permitted but guarded by reference checks. See the dedicated [permission_groups_rules.md](permission_groups_rules.md) file for the constraint implementation.

---

## 5. Default Password for Invited Users

When inviting new users via the `invite-user` Edge Function:
* Immediately after invoking `inviteUserByEmail`, the function calls `admin.updateUserById` to set their initial password to `'123456'`.
* This ensures that when the user taps their email confirmation/invitation link, their password is already preset, avoiding the need to choose a password from scratch.

