-- ==============================================================================
-- Migration: Add generate_due_maintenance_work_orders Function & pg_cron Schedule
-- ==============================================================================

-- 1. Create generate_due_maintenance_work_orders function
CREATE OR REPLACE FUNCTION public.generate_due_maintenance_work_orders()
RETURNS jsonb AS $$
DECLARE
  v_plan RECORD;
  v_location_id UUID;
  v_created_by_id UUID;
  v_new_wo_id UUID;
  v_new_next_due_date TIMESTAMP WITH TIME ZONE;
  v_generated_count INT := 0;
  v_error_count INT := 0;
  v_result jsonb;
BEGIN
  -- Iterate through all active, non-deleted plans whose next_due_date minus lead_time is due
  FOR v_plan IN
    SELECT mp.*
    FROM public.maintenance_plans mp
    WHERE mp.is_active = true
      AND mp.deleted_at IS NULL
      AND mp.next_due_date IS NOT NULL
      AND now() >= (mp.next_due_date - (COALESCE(mp.lead_time_days, 0) || ' days')::INTERVAL)
    ORDER BY mp.next_due_date ASC
    FOR UPDATE SKIP LOCKED
  LOOP
    BEGIN
      -- A. Resolve Location ID: prefer plan's location_id, fallback to asset's location_id
      v_location_id := v_plan.location_id;
      IF v_location_id IS NULL AND v_plan.asset_id IS NOT NULL THEN
        SELECT a.location_id INTO v_location_id
        FROM public.assets a
        WHERE a.id = v_plan.asset_id;
      END IF;

      IF v_location_id IS NULL THEN
        RAISE EXCEPTION 'Não foi possível determinar a localização do plano de manutenção.';
      END IF;

      -- B. Resolve Created By ID: assigned_to_id -> first active admin -> any active user profile in the company
      v_created_by_id := v_plan.assigned_to_id;
      IF v_created_by_id IS NULL THEN
        SELECT up.id INTO v_created_by_id
        FROM public.user_profiles up
        WHERE up.company_id = v_plan.company_id
          AND up.is_active = true
          AND up.deleted_at IS NULL
          AND up.is_admin = true
        ORDER BY up.created_at ASC
        LIMIT 1;
      END IF;

      IF v_created_by_id IS NULL THEN
        SELECT up.id INTO v_created_by_id
        FROM public.user_profiles up
        WHERE up.company_id = v_plan.company_id
          AND up.is_active = true
          AND up.deleted_at IS NULL
        ORDER BY up.created_at ASC
        LIMIT 1;
      END IF;

      IF v_created_by_id IS NULL THEN
        RAISE EXCEPTION 'Não foi possível determinar um usuário criador para a ordem de serviço.';
      END IF;

      -- C. Insert Work Order
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
        v_plan.next_due_date,
        CASE WHEN v_plan.duration_days IS NOT NULL THEN v_plan.duration_days * 24 * 60 ELSE NULL END,
        v_plan.price,
        COALESCE(v_plan.currency, 'BRL'),
        'internal'
      ) RETURNING id INTO v_new_wo_id;

      -- D. Calculate Next Due Date advancing from current next_due_date
      v_new_next_due_date := public.calculate_next_maintenance_plan_due_date(
        v_plan.next_due_date,
        v_plan.interval_value,
        v_plan.interval_unit,
        v_plan.day_of_week,
        v_plan.day_of_month,
        v_plan.month_of_year
      );

      -- E. Update Plan State
      UPDATE public.maintenance_plans
      SET last_generated_at = now(),
          last_generated_work_order_id = v_new_wo_id,
          next_due_date = v_new_next_due_date,
          last_error = NULL,
          updated_at = now()
      WHERE id = v_plan.id;

      v_generated_count := v_generated_count + 1;

    EXCEPTION WHEN OTHERS THEN
      -- Record failure on the plan record without aborting the loop
      UPDATE public.maintenance_plans
      SET last_error = SQLERRM,
          updated_at = now()
      WHERE id = v_plan.id;

      v_error_count := v_error_count + 1;
    END;
  END LOOP;

  v_result := jsonb_build_object(
    'success', true,
    'generated_count', v_generated_count,
    'error_count', v_error_count,
    'executed_at', now()
  );

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION public.generate_due_maintenance_work_orders() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.generate_due_maintenance_work_orders() FROM authenticated;
GRANT EXECUTE ON FUNCTION public.generate_due_maintenance_work_orders() TO service_role, postgres;


-- 2. Schedule hourly job in pg_cron
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Unschedule existing job if previously registered to maintain idempotency
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'generate-due-maintenance-work-orders') THEN
    PERFORM cron.unschedule('generate-due-maintenance-work-orders');
  END IF;
EXCEPTION WHEN OTHERS THEN
  -- Table cron.job might not exist in environments without pg_cron
  NULL;
END;
$$;

SELECT cron.schedule(
  'generate-due-maintenance-work-orders',
  '0 * * * *', -- At minute 0 of every hour
  $$ SELECT public.generate_due_maintenance_work_orders(); $$
);
