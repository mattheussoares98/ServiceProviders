-- Migration: rename duration_days to duration_hours on maintenance_plans and update functions

-- 1. Rename column and convert existing day values to hours
ALTER TABLE public.maintenance_plans
  RENAME COLUMN duration_days TO duration_hours;

ALTER TABLE public.maintenance_plans
  ALTER COLUMN duration_hours SET DEFAULT 8;

UPDATE public.maintenance_plans
  SET duration_hours = duration_hours * 24
  WHERE duration_hours IS NOT NULL;

-- 2. Update check constraint
ALTER TABLE public.maintenance_plans
  DROP CONSTRAINT IF EXISTS chk_mp_duration;

ALTER TABLE public.maintenance_plans
  ADD CONSTRAINT chk_mp_duration CHECK (duration_hours >= 0);

-- 3. Update generator function to use duration_hours * 60 for work order estimated_duration
CREATE OR REPLACE FUNCTION public.generate_maintenance_plan_work_orders(
    p_company_id UUID DEFAULT NULL,
    p_reference_date TIMESTAMPTZ DEFAULT NOW()
)
RETURNS TABLE (
    plan_id UUID,
    work_order_id UUID,
    status TEXT,
    error_message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_plan RECORD;
    v_wo_id UUID;
    v_next_due TIMESTAMPTZ;
    v_assigned_user_id UUID;
    v_sp_company_id UUID;
    v_checklist_id UUID;
    v_loc_id UUID;
    v_area_id UUID;
    v_asset_id UUID;
    v_wo_title VARCHAR(200);
BEGIN
    FOR v_plan IN
        SELECT mp.*
        FROM public.maintenance_plans mp
        WHERE mp.deleted_at IS NULL
          AND mp.is_active = TRUE
          AND (p_company_id IS NULL OR mp.company_id = p_company_id)
          AND (
              mp.next_due_date IS NULL
              OR mp.next_due_date <= (p_reference_date + (mp.lead_time_days || ' days')::INTERVAL)
          )
        ORDER BY mp.next_due_date ASC NULLS FIRST
        FOR UPDATE OF mp SKIP LOCKED
    LOOP
        BEGIN
            v_assigned_user_id := v_plan.assigned_to_id;
            v_sp_company_id := v_plan.service_provider_company_id;
            v_checklist_id := v_plan.checklist_template_id;
            v_loc_id := v_plan.location_id;
            v_area_id := v_plan.area_id;
            v_asset_id := v_plan.asset_id;

            -- Validate active references
            IF v_assigned_user_id IS NOT NULL THEN
                IF NOT EXISTS (
                    SELECT 1 FROM public.user_profiles
                    WHERE id = v_assigned_user_id
                      AND company_id = v_plan.company_id
                      AND deleted_at IS NULL
                      AND is_active = TRUE
                ) THEN
                    v_assigned_user_id := NULL;
                END IF;
            END IF;

            IF v_sp_company_id IS NOT NULL THEN
                IF NOT EXISTS (
                    SELECT 1 FROM public.companies
                    WHERE id = v_sp_company_id
                      AND deleted_at IS NULL
                ) THEN
                    v_sp_company_id := NULL;
                END IF;
            END IF;

            IF v_checklist_id IS NOT NULL THEN
                IF NOT EXISTS (
                    SELECT 1 FROM public.checklist_templates
                    WHERE id = v_checklist_id
                      AND company_id = v_plan.company_id
                      AND deleted_at IS NULL
                ) THEN
                    v_checklist_id := NULL;
                END IF;
            END IF;

            v_wo_title := LEFT(v_plan.title || ' - ' || TO_CHAR(COALESCE(v_plan.next_due_date, p_reference_date), 'DD/MM/YYYY'), 200);

            -- Create work order
            INSERT INTO public.work_orders (
                company_id,
                title,
                description,
                status,
                priority,
                maintenance_plan_id,
                location_id,
                area_id,
                asset_id,
                checklist_template_id,
                assigned_to_id,
                service_provider_company_id,
                estimated_duration,
                created_at,
                updated_at
            ) VALUES (
                v_plan.company_id,
                v_wo_title,
                v_plan.description,
                'open',
                v_plan.priority,
                v_plan.id,
                v_loc_id,
                v_area_id,
                v_asset_id,
                v_checklist_id,
                v_assigned_user_id,
                v_sp_company_id,
                CASE WHEN v_plan.duration_hours IS NOT NULL THEN v_plan.duration_hours * 60 ELSE NULL END,
                NOW(),
                NOW()
            )
            RETURNING id INTO v_wo_id;

            -- Calculate next due date
            v_next_due := public.calculate_next_maintenance_due_date(
                COALESCE(v_plan.next_due_date, p_reference_date),
                v_plan.interval_value,
                v_plan.interval_unit,
                v_plan.day_of_week,
                v_plan.day_of_month,
                v_plan.month_of_year
            );

            -- Update maintenance plan state
            UPDATE public.maintenance_plans
            SET last_generated_at = NOW(),
                last_generated_work_order_id = v_wo_id,
                last_error = NULL,
                next_due_date = v_next_due,
                updated_at = NOW()
            WHERE id = v_plan.id;

            plan_id := v_plan.id;
            work_order_id := v_wo_id;
            status := 'created';
            error_message := NULL;
            RETURN NEXT;

        EXCEPTION WHEN OTHERS THEN
            UPDATE public.maintenance_plans
            SET last_error = SQLERRM,
                updated_at = NOW()
            WHERE id = v_plan.id;

            plan_id := v_plan.id;
            work_order_id := NULL;
            status := 'error';
            error_message := SQLERRM;
            RETURN NEXT;
        END;
    END LOOP;
END;
$$;

-- 4. Update single plan generate RPC function
CREATE OR REPLACE FUNCTION public.generate_maintenance_plan_work_order(
    p_plan_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_caller_company_id UUID;
    v_plan RECORD;
    v_wo_id UUID;
    v_next_due TIMESTAMPTZ;
    v_assigned_user_id UUID;
    v_sp_company_id UUID;
    v_checklist_id UUID;
    v_loc_id UUID;
    v_area_id UUID;
    v_asset_id UUID;
    v_wo_title VARCHAR(200);
BEGIN
    SELECT company_id INTO v_caller_company_id
    FROM public.user_profiles
    WHERE id = auth.uid() AND deleted_at IS NULL;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado ou sem empresa vinculada';
    END IF;

    IF NOT public.has_permission('maintenance_plans:update') AND NOT public.has_permission('work_orders:create') THEN
        RAISE EXCEPTION 'Permissão negada para gerar ordem de serviço deste plano';
    END IF;

    SELECT * INTO v_plan
    FROM public.maintenance_plans
    WHERE id = p_plan_id
      AND company_id = v_caller_company_id
      AND deleted_at IS NULL
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Plano de manutenção não encontrado';
    END IF;

    IF NOT v_plan.is_active THEN
        RAISE EXCEPTION 'Plano de manutenção está inativo';
    END IF;

    v_assigned_user_id := v_plan.assigned_to_id;
    v_sp_company_id := v_plan.service_provider_company_id;
    v_checklist_id := v_plan.checklist_template_id;
    v_loc_id := v_plan.location_id;
    v_area_id := v_plan.area_id;
    v_asset_id := v_plan.asset_id;

    IF v_assigned_user_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE id = v_assigned_user_id
              AND company_id = v_plan.company_id
              AND deleted_at IS NULL
              AND is_active = TRUE
        ) THEN
            v_assigned_user_id := NULL;
        END IF;
    END IF;

    IF v_sp_company_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.companies
            WHERE id = v_sp_company_id
              AND deleted_at IS NULL
        ) THEN
            v_sp_company_id := NULL;
        END IF;
    END IF;

    IF v_checklist_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.checklist_templates
            WHERE id = v_checklist_id
              AND company_id = v_plan.company_id
              AND deleted_at IS NULL
        ) THEN
            v_checklist_id := NULL;
        END IF;
    END IF;

    v_wo_title := LEFT(v_plan.title || ' - ' || TO_CHAR(COALESCE(v_plan.next_due_date, NOW()), 'DD/MM/YYYY'), 200);

    INSERT INTO public.work_orders (
        company_id,
        title,
        description,
        status,
        priority,
        maintenance_plan_id,
        location_id,
        area_id,
        asset_id,
        checklist_template_id,
        assigned_to_id,
        service_provider_company_id,
        estimated_duration,
        created_at,
        updated_at
    ) VALUES (
        v_plan.company_id,
        v_wo_title,
        v_plan.description,
        'open',
        v_plan.priority,
        v_plan.id,
        v_loc_id,
        v_area_id,
        v_asset_id,
        v_checklist_id,
        v_assigned_user_id,
        v_sp_company_id,
        CASE WHEN v_plan.duration_hours IS NOT NULL THEN v_plan.duration_hours * 60 ELSE NULL END,
        NOW(),
        NOW()
    )
    RETURNING id INTO v_wo_id;

    v_next_due := public.calculate_next_maintenance_due_date(
        COALESCE(v_plan.next_due_date, NOW()),
        v_plan.interval_value,
        v_plan.interval_unit,
        v_plan.day_of_week,
        v_plan.day_of_month,
        v_plan.month_of_year
    );

    UPDATE public.maintenance_plans
    SET last_generated_at = NOW(),
        last_generated_work_order_id = v_wo_id,
        last_error = NULL,
        next_due_date = v_next_due,
        updated_at = NOW()
    WHERE id = v_plan.id;

    RETURN v_wo_id;
END;
$$;
