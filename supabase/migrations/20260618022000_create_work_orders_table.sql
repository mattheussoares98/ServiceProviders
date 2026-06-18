CREATE TABLE public.work_orders (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  asset_id UUID NULL REFERENCES public.assets(id) ON DELETE SET NULL,
  location_id UUID NOT NULL REFERENCES public.locations(id) ON DELETE CASCADE,
  assigned_to_id UUID NULL REFERENCES public.user_profiles(id) ON DELETE SET NULL,
  created_by_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  maintenance_plan_id UUID NULL,
  title VARCHAR(255) NOT NULL,
  description VARCHAR(2000) NULL,
  priority VARCHAR(50) NOT NULL DEFAULT 'medium',
  status VARCHAR(50) NOT NULL DEFAULT 'open',
  type VARCHAR(50) NOT NULL DEFAULT 'corrective',
  scheduled_date TIMESTAMP WITH TIME ZONE NULL,
  started_at TIMESTAMP WITH TIME ZONE NULL,
  completed_at TIMESTAMP WITH TIME ZONE NULL,
  estimated_duration INT NULL,
  actual_duration INT NULL,
  labor_cost NUMERIC NULL,
  parts_cost NUMERIC NULL,
  total_cost NUMERIC NULL,
  notes VARCHAR(2000) NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);

ALTER TABLE public.work_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own company work orders"
  ON public.work_orders FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company work orders"
  ON public.work_orders FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company work orders"
  ON public.work_orders FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE TRIGGER tr_prevent_delete_work_orders
BEFORE DELETE ON public.work_orders
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX idx_work_orders_company ON public.work_orders(company_id);
CREATE INDEX idx_work_orders_status ON public.work_orders(company_id, status);
CREATE INDEX idx_work_orders_assigned ON public.work_orders(company_id, assigned_to_id);
CREATE INDEX idx_work_orders_scheduled ON public.work_orders(company_id, scheduled_date);
