-- Unify approve_pause and approve_completion into manage_pending_requests permission

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

-- 2. Update existing permission_groups records
UPDATE public.permission_groups
SET permissions = permissions 
  - 'work_orders.approve_pause' 
  - 'work_orders.approve_completion'
  - 'work_orders.handle_status_changes'
  || jsonb_build_object(
    'work_orders.manage_pending_requests', 
    COALESCE(
      (permissions->>'work_orders.manage_pending_requests')::boolean,
      (permissions->>'work_orders.handle_status_changes')::boolean,
      (permissions->>'work_orders.approve_pause')::boolean,
      (permissions->>'work_orders.approve_completion')::boolean,
      false
    )
  )
WHERE jsonb_typeof(permissions) = 'object';

-- 3. Update existing user_profiles overrides if any
UPDATE public.user_profiles
SET permissions = permissions 
  - 'work_orders.approve_pause' 
  - 'work_orders.approve_completion'
  - 'work_orders.handle_status_changes'
  || jsonb_build_object(
    'work_orders.manage_pending_requests', 
    COALESCE(
      (permissions->>'work_orders.manage_pending_requests')::boolean,
      (permissions->>'work_orders.handle_status_changes')::boolean,
      (permissions->>'work_orders.approve_pause')::boolean,
      (permissions->>'work_orders.approve_completion')::boolean,
      false
    )
  )
WHERE permissions IS NOT NULL AND jsonb_typeof(permissions) = 'object';

-- 4. Update RLS policies for pause_reasons
DROP POLICY IF EXISTS "Company users manage own company pause reasons" ON public.pause_reasons;
CREATE POLICY "Company users manage own company pause reasons"
  ON public.pause_reasons FOR ALL TO authenticated
  USING (
    company_id = public.get_user_company_id() 
    AND (
      public.has_permission('work_orders.manage_pending_requests')
      OR public.has_permission('work_orders.approve_pause')
    )
  );

-- 5. Update RLS policies for work_order_pause_requests
DROP POLICY IF EXISTS "Users update work order pause requests" ON public.work_order_pause_requests;
CREATE POLICY "Users update work order pause requests"
  ON public.work_order_pause_requests FOR UPDATE
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND (
        public.has_permission('work_orders.manage_pending_requests')
        OR public.has_permission('work_orders.approve_pause')
        OR public.has_permission('work_orders.change_status')
        OR public.has_permission('work_orders.update')
      )
    )
    OR (
      requested_by_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      JOIN public.service_provider_profiles spp ON wo.service_provider_company_id = spp.service_provider_company_id
      WHERE wo.id = work_order_id AND spp.auth_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      WHERE wo.id = work_order_id AND wo.assigned_to_id = auth.uid()
    )
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      JOIN public.service_provider_profiles spp ON wo.service_provider_company_id = spp.service_provider_company_id
      WHERE wo.id = work_order_id AND spp.auth_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      WHERE wo.id = work_order_id AND wo.assigned_to_id = auth.uid()
    )
  );
