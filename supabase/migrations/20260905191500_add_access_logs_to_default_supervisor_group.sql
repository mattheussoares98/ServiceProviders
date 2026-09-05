-- Migration: 20260905191500_add_access_logs_to_default_supervisor_group.sql
-- Description: Add access_logs.read permission to default Supervisor group, handle_new_company trigger, and access_logs SELECT policy

-- 1. Update handle_new_company trigger function for newly created companies
CREATE OR REPLACE FUNCTION public.handle_new_company()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert Administrador group
  INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
  VALUES (gen_random_uuid(), NEW.id, 'Administrador', '{"*": true}'::jsonb, true, now());

  -- Insert Supervisor group
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
      "assets.create": true, "assets.update": true, "assets.delete": true,
      "locations.create": true, "locations.update": true, "locations.delete": true,
      "reports.create": true, "reports.update": true, "reports.delete": true,
      "attachments.create": true, "attachments.update": true, "attachments.delete": true,
      "checklists.create": true, "checklists.update": true, "checklists.delete": true,
      "maintenance_plans.create": true, "maintenance_plans.update": true, "maintenance_plans.delete": true,
      "users.read": true,
      "access_logs.read": true,
      "categories.create": true, "categories.update": true, "categories.delete": true,
      "sla_policies.create": true, "sla_policies.update": true, "sla_policies.delete": true,
      "sectors.create": true, "sectors.update": true, "sectors.delete": true,
      "service_providers.create": true, "service_providers.update": true, "service_providers.delete": true
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
      "attachments.create": true, "attachments.update": true,
      "checklists.update": true
    }'::jsonb, 
    true, now());

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Update existing default Supervisor groups to include access_logs.read
UPDATE public.permission_groups
SET permissions = permissions || '{"access_logs.read": true}'::jsonb
WHERE name = 'Supervisor' AND is_default = true;

-- 3. Update access_logs SELECT RLS policy to enforce access_logs.read permission
DROP POLICY IF EXISTS "Internal users can view access logs of their company" ON public.access_logs;
CREATE POLICY "Internal users can view access logs of their company"
    ON public.access_logs
    FOR SELECT
    TO authenticated
    USING (
        company_id = public.get_user_company_id()
        AND public.has_permission('access_logs.read')
    );
