-- ==============================================================================
-- Migration: Create Maintenance Plans Table, RLS, Indexes, Triggers & Realtime
-- ==============================================================================

-- 1. Create maintenance_plans Table
CREATE TABLE IF NOT EXISTS public.maintenance_plans (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  location_id UUID NULL REFERENCES public.locations(id) ON DELETE SET NULL,
  asset_id UUID NULL REFERENCES public.assets(id) ON DELETE SET NULL,
  area_id UUID NULL REFERENCES public.areas(id) ON DELETE SET NULL,
  assigned_to_id UUID NULL REFERENCES public.user_profiles(id) ON DELETE SET NULL,
  service_provider_company_id UUID NULL REFERENCES public.service_provider_companies(id) ON DELETE SET NULL,
  checklist_template_id UUID NULL REFERENCES public.checklist_templates(id) ON DELETE SET NULL,
  title VARCHAR(255) NOT NULL,
  description VARCHAR(2000) NULL,
  priority VARCHAR(50) NOT NULL DEFAULT 'medium',
  price NUMERIC(12,2) NULL,
  currency VARCHAR(3) NOT NULL DEFAULT 'BRL',
  interval_value INT NOT NULL DEFAULT 1,
  interval_unit VARCHAR(20) NOT NULL DEFAULT 'months',
  lead_time_days INT NOT NULL DEFAULT 0,
  duration_days INT NOT NULL DEFAULT 1,
  day_of_week INT NULL,
  day_of_month INT NULL,
  month_of_year INT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  last_generated_at TIMESTAMP WITH TIME ZONE NULL,
  last_generated_work_order_id UUID NULL,
  last_error VARCHAR(1000) NULL,
  next_due_date TIMESTAMP WITH TIME ZONE NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL,

  -- Constraints
  CONSTRAINT chk_mp_target CHECK (num_nonnulls(asset_id, location_id) >= 1),
  CONSTRAINT chk_mp_interval_value CHECK (interval_value > 0),
  CONSTRAINT chk_mp_interval_unit CHECK (interval_unit IN ('days', 'weeks', 'months', 'years')),
  CONSTRAINT chk_mp_lead_time CHECK (lead_time_days >= 0 AND lead_time_days <= 30),
  CONSTRAINT chk_mp_duration CHECK (duration_days >= 0),
  CONSTRAINT chk_mp_priority CHECK (priority IN ('low', 'medium', 'high', 'critical')),
  CONSTRAINT chk_mp_day_of_week CHECK (day_of_week IS NULL OR (day_of_week >= 1 AND day_of_week <= 7)),
  CONSTRAINT chk_mp_day_of_month CHECK (day_of_month IS NULL OR (day_of_month >= 1 AND day_of_month <= 31)),
  CONSTRAINT chk_mp_month_of_year CHECK (month_of_year IS NULL OR (month_of_year >= 1 AND month_of_year <= 12))
);

-- 2. Enable Row Level Security
ALTER TABLE public.maintenance_plans ENABLE ROW LEVEL SECURITY;

-- Read maintenance_plans: company users with maintenance_plans.read / admin
CREATE POLICY "Users read own company maintenance plans"
  ON public.maintenance_plans FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
  );

-- Insert maintenance_plans: company users with maintenance_plans.create permission
CREATE POLICY "Company users insert own company maintenance plans with permission"
  ON public.maintenance_plans FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('maintenance_plans.create')
  );

-- Update maintenance_plans: company users with maintenance_plans.update permission
CREATE POLICY "Company users update own company maintenance plans with permission"
  ON public.maintenance_plans FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND (
      public.has_permission('maintenance_plans.update')
      OR public.has_permission('maintenance_plans.delete')
    )
  );

-- 3. Delete Protection Triggers
CREATE TRIGGER tr_prevent_delete_maintenance_plans
BEFORE DELETE ON public.maintenance_plans
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

-- Soft Delete Dependency Check Function & Trigger
CREATE OR REPLACE FUNCTION public.check_maintenance_plans_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    IF EXISTS (
      SELECT 1 FROM public.work_orders wo
      WHERE wo.maintenance_plan_id = OLD.id
        AND wo.status != 'completed'
        AND wo.status != 'cancelled'
        AND wo.deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir um plano de manutenção vinculado a ordens de serviço em aberto.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_prevent_delete_maintenance_plans_with_relations
  BEFORE UPDATE ON public.maintenance_plans
  FOR EACH ROW
  EXECUTE FUNCTION public.check_maintenance_plans_before_delete();

-- 4. Foreign Key to work_orders
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'fk_work_orders_maintenance_plan'
  ) THEN
    ALTER TABLE public.work_orders
      ADD CONSTRAINT fk_work_orders_maintenance_plan
      FOREIGN KEY (maintenance_plan_id)
      REFERENCES public.maintenance_plans(id)
      ON DELETE SET NULL;
  END IF;
END;
$$;

-- Also add FK for last_generated_work_order_id in maintenance_plans
ALTER TABLE public.maintenance_plans
  ADD CONSTRAINT fk_maintenance_plans_last_generated_work_order
  FOREIGN KEY (last_generated_work_order_id)
  REFERENCES public.work_orders(id)
  ON DELETE SET NULL;

-- 5. Indexes
CREATE INDEX IF NOT EXISTS idx_maintenance_plans_company ON public.maintenance_plans(company_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_plans_location ON public.maintenance_plans(location_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_plans_asset ON public.maintenance_plans(asset_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_plans_due_active ON public.maintenance_plans(is_active, next_due_date) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_work_orders_maintenance_plan_id ON public.work_orders(maintenance_plan_id);

-- 6. Set REPLICA IDENTITY FULL for realtime delete / update streaming
ALTER TABLE public.maintenance_plans REPLICA IDENTITY FULL;

-- 7. Enable Realtime Publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.maintenance_plans;
