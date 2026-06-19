CREATE TABLE public.work_order_change_requests (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  work_order_id UUID NOT NULL REFERENCES public.work_orders(id) ON DELETE CASCADE,
  requested_by_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  change_type VARCHAR(50) NOT NULL,
  change_data JSONB NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  reviewed_by_id UUID NULL REFERENCES public.user_profiles(id) ON DELETE SET NULL,
  rejection_reason VARCHAR(1000) NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);

ALTER TABLE public.work_order_change_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own company work order change requests"
  ON public.work_order_change_requests FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company work order change requests"
  ON public.work_order_change_requests FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company work order change requests"
  ON public.work_order_change_requests FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE TRIGGER tr_prevent_delete_work_order_change_requests
BEFORE DELETE ON public.work_order_change_requests
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX idx_work_order_change_requests_company ON public.work_order_change_requests(company_id);
CREATE INDEX idx_work_order_change_requests_work_order ON public.work_order_change_requests(work_order_id);
CREATE INDEX idx_work_order_change_requests_status ON public.work_order_change_requests(company_id, status);
