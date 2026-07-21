-- ==========================================
-- SLA Policies Table
-- ==========================================
CREATE TABLE IF NOT EXISTS public.sla_policies (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  target_hours INTEGER NOT NULL,
  applies_to VARCHAR(20) NOT NULL DEFAULT 'both' CONSTRAINT chk_applies_to CHECK (applies_to IN ('provider', 'contractor', 'both')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);

ALTER TABLE public.sla_policies ENABLE ROW LEVEL SECURITY;

-- SLA Policies RLS Policies
CREATE POLICY "Users read own company sla policies"
  ON public.sla_policies FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.service_provider_profiles spp
      JOIN public.service_provider_companies spc ON spp.service_provider_company_id = spc.id
      WHERE spp.auth_user_id = auth.uid() AND spc.company_id = public.sla_policies.company_id
    )
  );

CREATE POLICY "Company users insert own company sla policies"
  ON public.sla_policies FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('sla_policies.create')
  );

CREATE POLICY "Company users update own company sla policies"
  ON public.sla_policies FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('sla_policies.update')
  );

CREATE TRIGGER tr_prevent_delete_sla_policies
BEFORE DELETE ON public.sla_policies
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX IF NOT EXISTS idx_sp_company ON public.sla_policies(company_id);

-- ==========================================
-- Work Order Pause Requests Table
-- ==========================================
CREATE TABLE IF NOT EXISTS public.work_order_pause_requests (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  work_order_id UUID NOT NULL REFERENCES public.work_orders(id) ON DELETE CASCADE,
  requested_by_id UUID NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  reason VARCHAR(255) NOT NULL,
  observation TEXT NULL,
  responsibility VARCHAR(20) NOT NULL CONSTRAINT chk_responsibility CHECK (responsibility IN ('provider', 'contractor', 'shared')),
  sector VARCHAR(100) NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending' CONSTRAINT chk_status CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled_by_provider')),
  paused_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  resumed_at TIMESTAMP WITH TIME ZONE NULL,
  reviewed_by_id UUID NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  review_observation TEXT NULL,
  affects_sla BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.work_order_pause_requests ENABLE ROW LEVEL SECURITY;

-- Work Order Pause Requests RLS Policies
CREATE POLICY "Users read own company work order pause requests"
  ON public.work_order_pause_requests FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      JOIN public.service_provider_profiles spp ON wo.service_provider_company_id = spp.service_provider_company_id
      WHERE wo.id = work_order_id AND spp.auth_user_id = auth.uid()
    )
  );

CREATE POLICY "Users insert work order pause requests"
  ON public.work_order_pause_requests FOR INSERT
  TO authenticated
  WITH CHECK (
    requested_by_id = auth.uid()
    AND (
      (
        company_id = public.get_user_company_id()
        AND public.has_permission('work_orders.change_status')
      )
      OR EXISTS (
        SELECT 1 FROM public.work_orders wo
        JOIN public.service_provider_profiles spp ON wo.service_provider_company_id = spp.service_provider_company_id
        WHERE wo.id = work_order_id AND spp.auth_user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Users update work order pause requests"
  ON public.work_order_pause_requests FOR UPDATE
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND public.has_permission('work_orders.approve_pause')
    )
    OR (
      requested_by_id = auth.uid()
      AND status = 'pending'
    )
  );

CREATE INDEX IF NOT EXISTS idx_wopr_work_order ON public.work_order_pause_requests(work_order_id);
CREATE INDEX IF NOT EXISTS idx_wopr_company ON public.work_order_pause_requests(company_id);

-- ==========================================
-- Work Orders — Add SLA Columns
-- ==========================================
ALTER TABLE public.work_orders
  ADD COLUMN IF NOT EXISTS sla_policy_id UUID NULL REFERENCES public.sla_policies(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS sla_deadline_at TIMESTAMP WITH TIME ZONE NULL,
  ADD COLUMN IF NOT EXISTS sla_breached BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS net_active_duration INTEGER NULL;

CREATE INDEX IF NOT EXISTS idx_work_orders_sla_policy ON public.work_orders(sla_policy_id);
