-- Add plan_type and work_type to companies table
ALTER TABLE public.companies
  ADD COLUMN IF NOT EXISTS plan_type VARCHAR(20) NOT NULL DEFAULT 'free',
  ADD COLUMN IF NOT EXISTS work_type VARCHAR(30) NOT NULL DEFAULT 'internal_only';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_companies_plan_type'
  ) THEN
    ALTER TABLE public.companies
      ADD CONSTRAINT chk_companies_plan_type
        CHECK (plan_type IN ('free', 'paid'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_companies_work_type'
  ) THEN
    ALTER TABLE public.companies
      ADD CONSTRAINT chk_companies_work_type
        CHECK (work_type IN ('internal_only', 'service_provider_only', 'hybrid'));
  END IF;
END;
$$;

-- Backfill existing companies to paid tier
UPDATE public.companies SET plan_type = 'paid' WHERE plan_type = 'free';

-- Add quota limit columns to company_parameters table (0 = unlimited)
ALTER TABLE public.company_parameters
  ADD COLUMN IF NOT EXISTS max_daily_work_orders INTEGER NOT NULL DEFAULT 0 CONSTRAINT chk_max_daily_work_orders CHECK (max_daily_work_orders >= 0),
  ADD COLUMN IF NOT EXISTS max_attachments_per_work_order INTEGER NOT NULL DEFAULT 0 CONSTRAINT chk_max_attachments_per_work_order CHECK (max_attachments_per_work_order >= 0),
  ADD COLUMN IF NOT EXISTS max_maintenance_plans INTEGER NOT NULL DEFAULT 0 CONSTRAINT chk_max_maintenance_plans CHECK (max_maintenance_plans >= 0),
  ADD COLUMN IF NOT EXISTS max_service_providers INTEGER NOT NULL DEFAULT 0 CONSTRAINT chk_max_service_providers CHECK (max_service_providers >= 0),
  ADD COLUMN IF NOT EXISTS max_observations_per_work_order INTEGER NOT NULL DEFAULT 0 CONSTRAINT chk_max_observations_per_work_order CHECK (max_observations_per_work_order >= 0);

-- Update trigger function to auto-provision default quotas based on company plan_type
CREATE OR REPLACE FUNCTION public.handle_new_company_parameters()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.company_parameters (
    company_id,
    max_daily_work_orders,
    max_attachments_per_work_order,
    max_maintenance_plans,
    max_service_providers,
    max_observations_per_work_order
  ) VALUES (
    NEW.id,
    CASE WHEN NEW.plan_type = 'free' THEN 3 ELSE 0 END,
    CASE WHEN NEW.plan_type = 'free' THEN 2 ELSE 0 END,
    0,
    0,
    CASE WHEN NEW.plan_type = 'free' THEN 2 ELSE 0 END
  )
  ON CONFLICT (company_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Work Order daily quota enforcement trigger
CREATE OR REPLACE FUNCTION public.enforce_work_order_daily_quota()
RETURNS TRIGGER AS $$
DECLARE
  v_max INT;
  v_today_count INT;
BEGIN
  SELECT cp.max_daily_work_orders INTO v_max
  FROM public.company_parameters cp
  WHERE cp.company_id = NEW.company_id;

  IF v_max = 0 OR v_max IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT count(*) INTO v_today_count
  FROM public.work_orders
  WHERE company_id = NEW.company_id
    AND created_at::date = now()::date
    AND deleted_at IS NULL;

  IF v_today_count >= v_max THEN
    RAISE EXCEPTION 'Limite diário de ordens de serviço atingido (% de %).', v_today_count, v_max;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_enforce_work_order_daily_quota ON public.work_orders;
CREATE TRIGGER tr_enforce_work_order_daily_quota
  BEFORE INSERT ON public.work_orders
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_work_order_daily_quota();

-- Attachment per-WO quota enforcement trigger
CREATE OR REPLACE FUNCTION public.enforce_attachment_quota()
RETURNS TRIGGER AS $$
DECLARE
  v_max INT;
  v_current_count INT;
BEGIN
  SELECT cp.max_attachments_per_work_order INTO v_max
  FROM public.company_parameters cp
  WHERE cp.company_id = NEW.company_id;

  IF v_max = 0 OR v_max IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT count(*) INTO v_current_count
  FROM public.attachments
  WHERE work_order_id = NEW.work_order_id
    AND company_id = NEW.company_id
    AND deleted_at IS NULL;

  IF v_current_count >= v_max THEN
    RAISE EXCEPTION 'Limite de anexos por ordem de serviço atingido (% de %).', v_current_count, v_max;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_enforce_attachment_quota ON public.attachments;
CREATE TRIGGER tr_enforce_attachment_quota
  BEFORE INSERT ON public.attachments
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_attachment_quota();

-- Observation per-WO quota enforcement trigger
CREATE OR REPLACE FUNCTION public.enforce_observation_quota()
RETURNS TRIGGER AS $$
DECLARE
  v_max INT;
  v_current_count INT;
BEGIN
  SELECT cp.max_observations_per_work_order INTO v_max
  FROM public.company_parameters cp
  WHERE cp.company_id = NEW.company_id;

  IF v_max = 0 OR v_max IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT count(*) INTO v_current_count
  FROM public.work_order_observations
  WHERE work_order_id = NEW.work_order_id
    AND company_id = NEW.company_id
    AND deleted_at IS NULL;

  IF v_current_count >= v_max THEN
    RAISE EXCEPTION 'Limite de observações por ordem de serviço atingido (% de %).', v_current_count, v_max;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_enforce_observation_quota ON public.work_order_observations;
CREATE TRIGGER tr_enforce_observation_quota
  BEFORE INSERT ON public.work_order_observations
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_observation_quota();

-- Maintenance plan feature gate trigger
CREATE OR REPLACE FUNCTION public.enforce_maintenance_plan_gate()
RETURNS TRIGGER AS $$
DECLARE
  v_plan_type VARCHAR;
  v_max INT;
BEGIN
  SELECT c.plan_type, cp.max_maintenance_plans
  INTO v_plan_type, v_max
  FROM public.companies c
  JOIN public.company_parameters cp ON cp.company_id = c.id
  WHERE c.id = NEW.company_id;

  IF v_plan_type = 'paid' OR v_max > 0 THEN
    RETURN NEW;
  END IF;

  RAISE EXCEPTION 'Planos de manutenção não estão disponíveis no plano gratuito.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_enforce_maintenance_plan_gate ON public.maintenance_plans;
CREATE TRIGGER tr_enforce_maintenance_plan_gate
  BEFORE INSERT ON public.maintenance_plans
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_maintenance_plan_gate();

-- Service provider feature gate trigger
CREATE OR REPLACE FUNCTION public.enforce_service_provider_gate()
RETURNS TRIGGER AS $$
DECLARE
  v_plan_type VARCHAR;
  v_max INT;
BEGIN
  SELECT c.plan_type, cp.max_service_providers
  INTO v_plan_type, v_max
  FROM public.companies c
  JOIN public.company_parameters cp ON cp.company_id = c.id
  WHERE c.id = NEW.company_id;

  IF v_plan_type = 'paid' OR v_max > 0 THEN
    RETURN NEW;
  END IF;

  RAISE EXCEPTION 'Prestadores de serviço não estão disponíveis no plano gratuito.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_enforce_service_provider_gate ON public.service_provider_companies;
CREATE TRIGGER tr_enforce_service_provider_gate
  BEFORE INSERT ON public.service_provider_companies
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_service_provider_gate();
