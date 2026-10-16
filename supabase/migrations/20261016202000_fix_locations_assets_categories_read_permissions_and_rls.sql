-- Migration: Fix read permissions and RLS for locations, areas, assets, and categories
-- 1. Update SELECT RLS policies to allow company members to read own company records directly
-- (matching customers, sectors, and sla_policies pattern), while preserving provider access.

-- Locations SELECT policy
DROP POLICY IF EXISTS "Users read own company locations with permission" ON public.locations;
DROP POLICY IF EXISTS "Users read own company locations" ON public.locations;
CREATE POLICY "Users read own company locations"
  ON public.locations FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR public.is_provider_of_company(company_id)
  );

-- Areas SELECT policy
DROP POLICY IF EXISTS "Users read own company areas with permission" ON public.areas;
DROP POLICY IF EXISTS "Users read own company areas" ON public.areas;
CREATE POLICY "Users read own company areas"
  ON public.areas FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR public.is_provider_of_company(company_id)
  );

-- Assets SELECT policy
DROP POLICY IF EXISTS "Users read own company assets with permission" ON public.assets;
DROP POLICY IF EXISTS "Users read own company assets" ON public.assets;
CREATE POLICY "Users read own company assets"
  ON public.assets FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR public.is_provider_referenced_asset(id)
  );

-- Categories SELECT policy
DROP POLICY IF EXISTS "Users read own company categories with permission" ON public.categories;
DROP POLICY IF EXISTS "Users read own company categories" ON public.categories;
CREATE POLICY "Users read own company categories"
  ON public.categories FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
  );

-- 2. Update handle_new_company function to seed explicit read permissions for standard resources
CREATE OR REPLACE FUNCTION public.handle_new_company()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert Administrador group
  INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
  VALUES (gen_random_uuid(), NEW.id, 'Administrador', '{"*": true}'::jsonb, true, now());

  -- Insert Supervisor group with all canonical permission keys including explicit read permissions
  INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
  VALUES (gen_random_uuid(), NEW.id, 'Supervisor', 
    '{
      "work_orders.read_scope": "all",
      "work_orders.create": true,
      "work_orders.update_scope": "all",
      "work_orders.delete": true,
      "work_orders.change_status": true,
      "work_orders.reassign": true,
      "work_orders.manage_pending_requests": true,
      "assets.read": true, "assets.create": true, "assets.update": true, "assets.delete": true,
      "locations.read": true, "locations.create": true, "locations.update": true, "locations.delete": true,
      "reports.read": true, "reports.create": true, "reports.update": true, "reports.delete": true,
      "attachments.read": true, "attachments.create": true, "attachments.update": true, "attachments.delete": true,
      "checklists.read": true, "checklists.create": true, "checklists.update": true, "checklists.delete": true,
      "maintenance_plans.read": true, "maintenance_plans.create": true, "maintenance_plans.update": true, "maintenance_plans.delete": true,
      "users.read": true,
      "access_logs.read": true,
      "categories.read": true, "categories.create": true, "categories.update": true, "categories.delete": true,
      "sla_policies.read": true, "sla_policies.create": true, "sla_policies.update": true, "sla_policies.delete": true,
      "sectors.read": true, "sectors.create": true, "sectors.update": true, "sectors.delete": true,
      "service_providers.read": true, "service_providers.create": true, "service_providers.update": true, "service_providers.delete": true,
      "customers.read": true, "customers.create": true, "customers.update": true, "customers.delete": true
    }'::jsonb, 
    true, now());

  -- Insert Técnico group
  INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
  VALUES (gen_random_uuid(), NEW.id, 'Técnico', 
    '{
      "work_orders.read_scope": "assigned",
      "work_orders.create": false,
      "work_orders.update_scope": "assigned",
      "work_orders.delete": false,
      "work_orders.change_status": true,
      "work_orders.reassign": false,
      "work_orders.manage_pending_requests": false,
      "locations.read": true,
      "assets.read": true,
      "categories.read": true,
      "attachments.create": true, "attachments.update": true,
      "checklists.update": true
    }'::jsonb, 
    true, now());

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Reconcile existing Supervisor and Técnico groups to ensure explicit read permissions are present
UPDATE public.permission_groups
SET permissions = permissions || '{
  "locations.read": true,
  "assets.read": true,
  "categories.read": true,
  "customers.read": true,
  "reports.read": true,
  "attachments.read": true,
  "checklists.read": true,
  "maintenance_plans.read": true,
  "sla_policies.read": true,
  "sectors.read": true,
  "service_providers.read": true
}'::jsonb
WHERE name = 'Supervisor' AND jsonb_typeof(permissions) = 'object';

UPDATE public.permission_groups
SET permissions = permissions || '{
  "locations.read": true,
  "assets.read": true,
  "categories.read": true
}'::jsonb
WHERE name = 'Técnico' AND jsonb_typeof(permissions) = 'object';
