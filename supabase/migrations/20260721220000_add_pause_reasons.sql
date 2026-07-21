-- ==========================================
-- Pause Reasons Table
-- ==========================================
CREATE TABLE IF NOT EXISTS public.pause_reasons (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);

ALTER TABLE public.pause_reasons ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Pause Reasons
CREATE POLICY "Users read own company pause reasons"
  ON public.pause_reasons FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.service_provider_profiles spp
      JOIN public.service_provider_companies spc ON spp.service_provider_company_id = spc.id
      WHERE spp.auth_user_id = auth.uid() AND spc.company_id = public.pause_reasons.company_id
    )
  );

CREATE POLICY "Company users manage own company pause reasons"
  ON public.pause_reasons FOR ALL
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.approve_pause')
  );

CREATE TRIGGER tr_prevent_delete_pause_reasons
BEFORE DELETE ON public.pause_reasons
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX IF NOT EXISTS idx_pr_company ON public.pause_reasons(company_id);

-- ==========================================
-- Alter Work Order Pause Requests
-- ==========================================
ALTER TABLE public.work_order_pause_requests 
  RENAME COLUMN reason TO custom_reason;

ALTER TABLE public.work_order_pause_requests 
  ALTER COLUMN custom_reason DROP NOT NULL;

ALTER TABLE public.work_order_pause_requests 
  ADD COLUMN reason_id UUID NULL REFERENCES public.pause_reasons(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_wopr_reason ON public.work_order_pause_requests(reason_id);

-- Seed some default pause reasons for existing companies
INSERT INTO public.pause_reasons (company_id, name)
SELECT id, 'Aguardando material' FROM public.companies
UNION ALL
SELECT id, 'Área bloqueada / sem acesso' FROM public.companies
UNION ALL
SELECT id, 'Aguardando liberação do cliente' FROM public.companies
UNION ALL
SELECT id, 'Condições climáticas adversas' FROM public.companies;
