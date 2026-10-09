-- Migration: Add customer_id to maintenance_plans and adapt generation functions
-- 1. Add customer_id column to maintenance_plans table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'maintenance_plans' AND column_name = 'customer_id'
  ) THEN
    ALTER TABLE public.maintenance_plans 
      ADD COLUMN customer_id UUID NULL REFERENCES public.customers(id) ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_maintenance_plans_customer ON public.maintenance_plans(customer_id);

-- 2. Update target constraint to support customers
ALTER TABLE public.maintenance_plans
  DROP CONSTRAINT IF EXISTS chk_mp_target;

ALTER TABLE public.maintenance_plans
  ADD CONSTRAINT chk_mp_target CHECK (num_nonnulls(location_id, customer_id) >= 1);

-- 3. Enforce company work_type target validation on maintenance_plans
CREATE OR REPLACE FUNCTION public.enforce_maintenance_plan_work_type_rules()
RETURNS TRIGGER AS $$
DECLARE
  v_work_type VARCHAR;
BEGIN
  SELECT work_type INTO v_work_type
  FROM public.companies
  WHERE id = NEW.company_id;

  -- internal_only requires location
  IF v_work_type = 'internal_only' AND NEW.location_id IS NULL THEN
    RAISE EXCEPTION 'Selecione um local para o plano de manutenção.';
  END IF;

  -- service_provider_only requires customer
  IF v_work_type = 'service_provider_only' AND NEW.customer_id IS NULL THEN
    RAISE EXCEPTION 'Selecione um cliente para o plano de manutenção.';
  END IF;

  -- hybrid requires location or customer
  IF v_work_type = 'hybrid' AND NEW.location_id IS NULL AND NEW.customer_id IS NULL THEN
    RAISE EXCEPTION 'Selecione um local ou cliente para o plano de manutenção.';
  END IF;

  -- hybrid cannot have both customer and service provider company
  IF v_work_type = 'hybrid' AND NEW.customer_id IS NOT NULL AND NEW.service_provider_company_id IS NOT NULL THEN
    RAISE EXCEPTION 'Não é permitido selecionar o cliente e o prestador de serviços.';
  END IF;

  -- fallback if work_type is unknown / null
  IF v_work_type IS NULL AND NEW.location_id IS NULL AND NEW.customer_id IS NULL THEN
    RAISE EXCEPTION 'Selecione um local para o plano de manutenção.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_enforce_maintenance_plan_work_type_rules ON public.maintenance_plans;
CREATE TRIGGER tr_enforce_maintenance_plan_work_type_rules
  BEFORE INSERT OR UPDATE ON public.maintenance_plans
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_maintenance_plan_work_type_rules();

-- 4. Update soft-delete protection on customers to check maintenance plans
CREATE OR REPLACE FUNCTION public.check_customer_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    IF EXISTS (
      SELECT 1 
      FROM public.work_orders 
      WHERE customer_id = OLD.id 
        AND status != 'completed' 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir este cliente porque ele possui ordens de serviço ativas.';
    END IF;

    IF EXISTS (
      SELECT 1 
      FROM public.maintenance_plans 
      WHERE customer_id = OLD.id 
        AND is_active = true 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir este cliente porque ele possui planos de manutenção ativos.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Update generate_maintenance_plan_work_order RPC to support customer_id
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
    v_cust_id UUID;
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
    v_cust_id := v_plan.customer_id;

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
        customer_id,
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
        v_cust_id,
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
    WHERE id = p_plan_id;

    RETURN v_wo_id;
END;
$$;

-- 4. Update batch generation function
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
    v_cust_id UUID;
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
            v_cust_id := v_plan.customer_id;

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

            INSERT INTO public.work_orders (
                company_id,
                title,
                description,
                status,
                priority,
                maintenance_plan_id,
                location_id,
                customer_id,
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
                v_cust_id,
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
                COALESCE(v_plan.next_due_date, p_reference_date),
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

            plan_id := v_plan.id;
            work_order_id := v_wo_id;
            status := 'success';
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
