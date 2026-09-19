-- ==============================================================================
-- Migration: Add generate_maintenance_plan_work_order RPC for On-Demand Generation
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.generate_maintenance_plan_work_order(
  p_plan_id UUID
)
RETURNS UUID AS $$
DECLARE
  v_plan RECORD;
  v_caller_company_id UUID;
  v_location_id UUID;
  v_created_by_id UUID := auth.uid();
  v_new_wo_id UUID;
  v_new_next_due_date TIMESTAMP WITH TIME ZONE;
BEGIN
  -- 1. Tenant & Permission Verification
  v_caller_company_id := public.get_user_company_id();
  IF v_caller_company_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado ou sem empresa vinculada.';
  END IF;

  IF NOT (
    public.has_permission('maintenance_plans.update')
    OR public.has_permission('work_orders.create')
  ) THEN
    RAISE EXCEPTION 'Permissão insuficiente para gerar ordem de serviço.';
  END IF;

  -- 2. Fetch Plan with Row Lock
  SELECT mp.*
  INTO v_plan
  FROM public.maintenance_plans mp
  WHERE mp.id = p_plan_id
    AND mp.company_id = v_caller_company_id
    AND mp.deleted_at IS NULL
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Plano de manutenção não encontrado.';
  END IF;

  -- 3. Resolve Location ID: prefer plan's location_id, fallback to asset's location_id
  v_location_id := v_plan.location_id;
  IF v_location_id IS NULL AND v_plan.asset_id IS NOT NULL THEN
    SELECT a.location_id INTO v_location_id
    FROM public.assets a
    WHERE a.id = v_plan.asset_id;
  END IF;

  IF v_location_id IS NULL THEN
    RAISE EXCEPTION 'Não foi possível determinar a localização do plano de manutenção.';
  END IF;

  -- 4. Resolve Created By ID: caller auth.uid(), or fallback to assigned_to_id
  IF v_created_by_id IS NULL THEN
    v_created_by_id := v_plan.assigned_to_id;
  END IF;

  IF v_created_by_id IS NULL THEN
    RAISE EXCEPTION 'Não foi possível determinar o usuário criador da ordem de serviço.';
  END IF;

  -- 5. Insert Work Order
  INSERT INTO public.work_orders (
    company_id,
    location_id,
    asset_id,
    area_id,
    assigned_to_id,
    created_by_id,
    maintenance_plan_id,
    service_provider_company_id,
    checklist_template_id,
    title,
    description,
    priority,
    status,
    type,
    scheduled_date,
    estimated_duration,
    price,
    currency,
    opened_by
  ) VALUES (
    v_plan.company_id,
    v_location_id,
    v_plan.asset_id,
    v_plan.area_id,
    v_plan.assigned_to_id,
    v_created_by_id,
    v_plan.id,
    v_plan.service_provider_company_id,
    v_plan.checklist_template_id,
    v_plan.title,
    v_plan.description,
    v_plan.priority,
    'open',
    'preventive',
    COALESCE(v_plan.next_due_date, now()),
    CASE WHEN v_plan.duration_days IS NOT NULL THEN v_plan.duration_days * 24 * 60 ELSE NULL END,
    v_plan.price,
    COALESCE(v_plan.currency, 'BRL'),
    'internal'
  ) RETURNING id INTO v_new_wo_id;

  -- 6. Advance Next Due Date
  v_new_next_due_date := public.calculate_next_maintenance_plan_due_date(
    COALESCE(v_plan.next_due_date, now()),
    v_plan.interval_value,
    v_plan.interval_unit,
    v_plan.day_of_week,
    v_plan.day_of_month,
    v_plan.month_of_year
  );

  -- 7. Update Plan Metadata
  UPDATE public.maintenance_plans
  SET last_generated_at = now(),
      last_generated_work_order_id = v_new_wo_id,
      next_due_date = v_new_next_due_date,
      last_error = NULL,
      updated_at = now()
  WHERE id = v_plan.id;

  RETURN v_new_wo_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION public.generate_maintenance_plan_work_order(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.generate_maintenance_plan_work_order(UUID) TO authenticated, service_role;
