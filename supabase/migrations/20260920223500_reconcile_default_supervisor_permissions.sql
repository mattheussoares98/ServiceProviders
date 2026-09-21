-- Reconcile default Supervisor permissions in handle_new_company and existing groups
CREATE OR REPLACE FUNCTION public.handle_new_company()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert Administrador group
  INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
  VALUES (gen_random_uuid(), NEW.id, 'Administrador', '{"*": true}'::jsonb, true, now());

  -- Insert Supervisor group with all canonical permission keys
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

-- Reconcile existing Supervisor permission groups
UPDATE public.permission_groups
SET permissions = permissions 
  - 'work_orders.approve_pause' 
  - 'work_orders.approve_completion'
  - 'work_orders.handle_status_changes'
  || '{
    "work_orders.read_scope": "all",
    "work_orders.update_scope": "all",
    "work_orders.manage_pending_requests": true
  }'::jsonb
WHERE name = 'Supervisor' AND jsonb_typeof(permissions) = 'object';

-- Reconcile existing user_profiles overrides if any
UPDATE public.user_profiles
SET permissions = permissions 
  - 'work_orders.approve_pause' 
  - 'work_orders.approve_completion'
  - 'work_orders.handle_status_changes'
  || '{"work_orders.manage_pending_requests": true}'::jsonb
WHERE permissions IS NOT NULL 
  AND jsonb_typeof(permissions) = 'object'
  AND (
    (permissions->>'work_orders.approve_pause')::boolean = true
    OR (permissions->>'work_orders.approve_completion')::boolean = true
    OR (permissions->>'work_orders.handle_status_changes')::boolean = true
  );
