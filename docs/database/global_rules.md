# Database Global Rules & Security

This document details the global rules, Row Level Security (RLS) policies, and deletion triggers configured on the remote Supabase (PostgreSQL) database.

---

## 1. Row Level Security (RLS)

Row Level Security is enabled on all tables in the `public` schema. By default, any operation that is not explicitly permitted by a policy is blocked for non-superusers.

### Multi-Tenant Context Helper

The database uses a security definer helper function to resolve the tenant (company) of the currently authenticated user:

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

The database uses a security definer helper function to check if the currently authenticated user is an administrator:

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

### Table Policies

#### companies

```sql
CREATE POLICY "Users read own company"
  ON public.companies FOR SELECT
  TO authenticated
  USING (id = public.get_user_company_id() OR public.is_admin());

CREATE POLICY "Admins can insert companies"
  ON public.companies FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

CREATE POLICY "Users update own company"
  ON public.companies FOR UPDATE
  TO authenticated
  USING (id = public.get_user_company_id() OR public.is_admin());
  //TODO respect the permission group from the user
```

#### permission_groups

```sql
CREATE POLICY "Users read own company permission groups"
  ON public.permission_groups FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user

CREATE POLICY "Users insert own company permission groups"
  ON public.permission_groups FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user

CREATE POLICY "Users update own company permission groups"
  ON public.permission_groups FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user

CREATE POLICY "Users delete own company permission groups"
  ON public.permission_groups FOR DELETE
  TO authenticated
  USING (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user
```


#### user_profiles

```sql
CREATE POLICY "Users read own company user profiles"
  ON public.user_profiles FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user

CREATE POLICY "Users insert own company user profiles"
  ON public.user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());
  //TODO respect the permission group from the user

CREATE POLICY "Users update own profile"
  ON public.user_profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid());
  //TODO respect the permission group from the user
```

#### locations

```sql
CREATE POLICY "Users read own company locations"
  ON public.locations FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company locations"
  ON public.locations FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company locations"
  ON public.locations FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
```

#### areas

```sql
CREATE POLICY "Users read own company areas"
  ON public.areas FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company areas"
  ON public.areas FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company areas"
  ON public.areas FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
```


---

## 2. Soft Delete Policy

Any table that contains a `deleted_at` column is restricted from hard deletion. RLS `DELETE` policies must be omitted for these tables, and a database trigger is assigned to block hard deletion attempts.

Instead of a hard `DELETE` query, clients must perform an `UPDATE` query setting the `deleted_at` column to the current timestamp.

### Hard Delete Prevention Trigger

```sql
CREATE OR REPLACE FUNCTION public.prevent_delete()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'Hard deletes are disabled. Use soft delete by setting deleted_at instead.';
END;
$$ LANGUAGE plpgsql;
```

#### Applied Tables:
- **companies** (`tr_prevent_delete_companies` trigger)
- **user_profiles** (`tr_prevent_delete_user_profiles` trigger)
- **locations** (`tr_prevent_delete_locations` trigger)
- **areas** (`tr_prevent_delete_areas` trigger)

```sql
CREATE TRIGGER tr_prevent_delete_companies
BEFORE DELETE ON public.companies
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE TRIGGER tr_prevent_delete_user_profiles
BEFORE DELETE ON public.user_profiles
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE TRIGGER tr_prevent_delete_locations
BEFORE DELETE ON public.locations
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE TRIGGER tr_prevent_delete_areas
BEFORE DELETE ON public.areas
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();
```

---

## 3. Safe Deletion & Reference Checks

For tables that do not support soft delete (e.g. `permission_groups`), hard deletion is permitted but strictly guarded. Deletion is blocked if there are active references in other tables to prevent invalid foreign key states or orphaned relationships.

### Permission Groups Delete Constraint

A `permission_group` row cannot be deleted if there are any `user_profiles` referencing it.

```sql
CREATE OR REPLACE FUNCTION public.check_permission_group_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE permission_group_id = OLD.id
  ) THEN
    RAISE EXCEPTION 'Cannot delete permission group because it is assigned to one or more user profiles.';
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_check_permission_group_delete
BEFORE DELETE ON public.permission_groups
FOR EACH ROW
EXECUTE FUNCTION public.check_permission_group_delete();
```
