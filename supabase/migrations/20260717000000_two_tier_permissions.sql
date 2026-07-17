-- Update has_permission helper function to support both old array and new flat object structure
CREATE OR REPLACE FUNCTION public.has_permission(permission_key TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  v_is_admin BOOLEAN;
  v_permissions JSONB;
BEGIN
  -- Get user profile details
  SELECT 
    up.is_admin,
    COALESCE(pg.permissions, '{}'::jsonb)
  INTO 
    v_is_admin,
    v_permissions
  FROM public.user_profiles up
  LEFT JOIN public.permission_groups pg ON up.permission_group_id = pg.id
  WHERE up.id = auth.uid();

  -- Admin has all permissions
  IF COALESCE(v_is_admin, false) OR (jsonb_typeof(v_permissions) = 'array' AND v_permissions ? '*') OR (jsonb_typeof(v_permissions) = 'object' AND COALESCE((v_permissions ->> '*')::boolean, false)) THEN
    RETURN TRUE;
  END IF;

  -- Support old array format
  IF jsonb_typeof(v_permissions) = 'array' THEN
    RETURN v_permissions ? permission_key;
  -- Support new flat object format
  ELSIF jsonb_typeof(v_permissions) = 'object' THEN
    -- If it's a scope value (e.g. read_scope, update_scope), check if it's not 'none'
    IF permission_key LIKE '%.read_scope' OR permission_key LIKE '%.update_scope' THEN
      RETURN COALESCE((v_permissions ->> permission_key) IS NOT NULL AND (v_permissions ->> permission_key) <> 'none', false);
    ELSE
      -- Handle fallback lookup (if key is boolean)
      RETURN COALESCE((v_permissions -> permission_key)::boolean, false);
    END IF;
  END IF;

  RETURN FALSE;
END;
$$;

-- Create helper function to check work orders read scope
CREATE OR REPLACE FUNCTION public.get_work_orders_read_scope()
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  v_is_admin BOOLEAN;
  v_permissions JSONB;
BEGIN
  SELECT 
    up.is_admin,
    COALESCE(pg.permissions, '{}'::jsonb)
  INTO 
    v_is_admin,
    v_permissions
  FROM public.user_profiles up
  LEFT JOIN public.permission_groups pg ON up.permission_group_id = pg.id
  WHERE up.id = auth.uid();

  IF COALESCE(v_is_admin, false) THEN
    RETURN 'all';
  END IF;

  IF jsonb_typeof(v_permissions) = 'array' THEN
    IF v_permissions ? 'work_orders.read' THEN
      RETURN 'all';
    ELSE
      RETURN 'assigned';
    END IF;
  ELSIF jsonb_typeof(v_permissions) = 'object' THEN
    RETURN COALESCE(v_permissions ->> 'work_orders.read_scope', 'assigned');
  END IF;

  RETURN 'assigned';
END;
$$;

-- Create helper function to check work orders update scope
CREATE OR REPLACE FUNCTION public.get_work_orders_update_scope()
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  v_is_admin BOOLEAN;
  v_permissions JSONB;
BEGIN
  SELECT 
    up.is_admin,
    COALESCE(pg.permissions, '{}'::jsonb)
  INTO 
    v_is_admin,
    v_permissions
  FROM public.user_profiles up
  LEFT JOIN public.permission_groups pg ON up.permission_group_id = pg.id
  WHERE up.id = auth.uid();

  IF COALESCE(v_is_admin, false) THEN
    RETURN 'all';
  END IF;

  IF jsonb_typeof(v_permissions) = 'array' THEN
    IF v_permissions ? 'work_orders.update' THEN
      RETURN 'all';
    ELSIF v_permissions ? 'work_orders.read' THEN
      RETURN 'assigned';
    ELSE
      RETURN 'none';
    END IF;
  ELSIF jsonb_typeof(v_permissions) = 'object' THEN
    RETURN COALESCE(v_permissions ->> 'work_orders.update_scope', 'none');
  END IF;

  RETURN 'none';
END;
$$;

-- Recreate policies on public.work_orders table to enforce scope-based visibility
DROP POLICY IF EXISTS "Users read own company work orders with permission" ON public.work_orders;
CREATE POLICY "Users read own company work orders with permission"
  ON public.work_orders FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND (
      public.get_work_orders_read_scope() = 'all'
      OR (public.get_work_orders_read_scope() = 'assigned' AND assigned_to_id = auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users update own company work orders with permission" ON public.work_orders;
CREATE POLICY "Users update own company work orders with permission"
  ON public.work_orders FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND (
      public.get_work_orders_update_scope() = 'all'
      OR (public.get_work_orders_update_scope() = 'assigned' AND assigned_to_id = auth.uid())
      OR (public.get_work_orders_update_scope() = 'own' AND created_by_id = auth.uid())
    )
  );

-- Migrate existing permission groups from JSON array to JSON object format
DO $$
DECLARE
  v_row RECORD;
  v_permissions JSONB;
  v_new_permissions JSONB;
  v_item TEXT;
  v_resource TEXT;
  v_action TEXT;
  v_parts TEXT[];
BEGIN
  FOR v_row IN SELECT id, permissions FROM public.permission_groups LOOP
    v_permissions := v_row.permissions;
    
    IF jsonb_typeof(v_permissions) = 'array' THEN
      v_new_permissions := '{}'::jsonb;
      
      -- If array contains '*', map to administrator permissions
      IF v_permissions ? '*' THEN
        v_new_permissions := jsonb_build_object('*', true);
      ELSE
        -- Default work_orders scopes depending on old read/update permissions
        IF v_permissions ? 'work_orders.read' THEN
          v_new_permissions := jsonb_set(v_new_permissions, '{work_orders.read_scope}', '"all"');
        ELSE
          v_new_permissions := jsonb_set(v_new_permissions, '{work_orders.read_scope}', '"assigned"');
        END IF;

        IF v_permissions ? 'work_orders.update' THEN
          v_new_permissions := jsonb_set(v_new_permissions, '{work_orders.update_scope}', '"all"');
          v_new_permissions := jsonb_set(v_new_permissions, '{work_orders.change_status}', 'true');
        ELSIF v_permissions ? 'work_orders.read' THEN
          v_new_permissions := jsonb_set(v_new_permissions, '{work_orders.update_scope}', '"assigned"');
          v_new_permissions := jsonb_set(v_new_permissions, '{work_orders.change_status}', 'true');
        ELSE
          v_new_permissions := jsonb_set(v_new_permissions, '{work_orders.update_scope}', '"none"');
        END IF;

        -- Loop through and migrate all array keys
        FOR v_item IN SELECT jsonb_array_elements_text(v_permissions) LOOP
          v_parts := string_to_array(v_item, '.');
          IF array_length(v_parts, 1) = 2 THEN
            v_resource := v_parts[1];
            v_action := v_parts[2];
            
            -- Skip work orders read/update as they are mapped to scopes above
            IF v_resource <> 'work_orders' OR (v_action <> 'read' AND v_action <> 'update') THEN
              v_new_permissions := jsonb_set(v_new_permissions, array[v_item], 'true');
            END IF;
          END IF;
        END LOOP;
      END IF;

      -- Update the row
      UPDATE public.permission_groups 
      SET permissions = v_new_permissions 
      WHERE id = v_row.id;
    END IF;
  END LOOP;
END;
$$;

-- Update the new company handler trigger to seed default groups using the new JSON object structure
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
      "work_orders.approve_pause": true,
      "work_orders.approve_completion": true,
      "assets.create": true, "assets.update": true, "assets.delete": true,
      "locations.create": true, "locations.update": true, "locations.delete": true,
      "reports.create": true, "reports.update": true, "reports.delete": true,
      "attachments.create": true, "attachments.update": true, "attachments.delete": true,
      "checklists.create": true, "checklists.update": true, "checklists.delete": true,
      "maintenance_plans.create": true, "maintenance_plans.update": true, "maintenance_plans.delete": true,
      "users.read": true,
      "categories.create": true, "categories.update": true, "categories.delete": true
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
      "work_orders.approve_pause": false,
      "work_orders.approve_completion": false,
      "attachments.create": true, "attachments.update": true,
      "checklists.update": true
    }'::jsonb, 
    true, now());

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
