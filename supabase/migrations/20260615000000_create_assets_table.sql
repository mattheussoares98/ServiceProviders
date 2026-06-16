CREATE TABLE public.assets (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  area_id UUID NOT NULL REFERENCES public.areas(id) ON DELETE CASCADE,
  category_id UUID NULL,
  parent_asset_id UUID NULL REFERENCES public.assets(id) ON DELETE SET NULL,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(100) NULL,
  manufacturer VARCHAR(100) NULL,
  model VARCHAR(100) NULL,
  serial_number VARCHAR(100) NULL,
  install_date DATE NULL,
  warranty_expiration DATE NULL,
  revision_forecast DATE NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  criticality VARCHAR(50) NOT NULL DEFAULT 'medium',
  notes VARCHAR(2000) NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL,
  CONSTRAINT unique_code_per_company UNIQUE (company_id, code),
  CONSTRAINT unique_serial_number_per_company UNIQUE (company_id, serial_number)
);

ALTER TABLE public.assets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own company assets"
  ON public.assets FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company assets"
  ON public.assets FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company assets"
  ON public.assets FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE TRIGGER tr_prevent_delete_assets
BEFORE DELETE ON public.assets
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();
