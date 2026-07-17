-- ==========================================
-- Service Provider Companies
-- ==========================================
CREATE TABLE public.service_provider_companies (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  document VARCHAR(14) NULL,
  document_type VARCHAR(4) NULL,
  contact_email VARCHAR(255) NULL,
  contact_phone VARCHAR(30) NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),

  CONSTRAINT chk_document_consistency
    CHECK (
      (document IS NULL AND document_type IS NULL)
      OR (document IS NOT NULL AND document_type IS NOT NULL)
    ),
  CONSTRAINT chk_document_type
    CHECK (document_type IN ('cpf', 'cnpj'))
);

ALTER TABLE public.service_provider_companies ENABLE ROW LEVEL SECURITY;

-- Internal company employees can manage providers their company owns.
CREATE POLICY "Company users read own service provider companies"
  ON public.service_provider_companies FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Company users insert service provider companies"
  ON public.service_provider_companies FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('service_providers.create')
  );

CREATE POLICY "Company users update service provider companies"
  ON public.service_provider_companies FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('service_providers.update')
  );

CREATE TRIGGER tr_prevent_delete_service_provider_companies
BEFORE DELETE ON public.service_provider_companies
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX idx_spc_company ON public.service_provider_companies(company_id);

-- ==========================================
-- Service Provider Profiles
-- ==========================================
CREATE TABLE public.service_provider_profiles (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id UUID NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  service_provider_company_id UUID NOT NULL
    REFERENCES public.service_provider_companies(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(30) NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.service_provider_profiles ENABLE ROW LEVEL SECURITY;

-- Contracting company users can read profiles belonging to their providers.
CREATE POLICY "Company users read provider profiles of their companies"
  ON public.service_provider_profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.service_provider_companies spc
      WHERE spc.id = service_provider_company_id
        AND spc.company_id = public.get_user_company_id()
    )
  );

CREATE POLICY "Company users insert provider profiles"
  ON public.service_provider_profiles FOR INSERT
  TO authenticated
  WITH CHECK (
    public.has_permission('service_providers.create')
    AND EXISTS (
      SELECT 1 FROM public.service_provider_companies spc
      WHERE spc.id = service_provider_company_id
        AND spc.company_id = public.get_user_company_id()
    )
  );

CREATE POLICY "Company users update provider profiles"
  ON public.service_provider_profiles FOR UPDATE
  TO authenticated
  USING (
    public.has_permission('service_providers.update')
    AND EXISTS (
      SELECT 1 FROM public.service_provider_companies spc
      WHERE spc.id = service_provider_company_id
        AND spc.company_id = public.get_user_company_id()
    )
  );

-- Provider users can read their own profile.
CREATE POLICY "Provider users read their own profile"
  ON public.service_provider_profiles FOR SELECT
  TO authenticated
  USING (auth_user_id = auth.uid());

CREATE TRIGGER tr_prevent_delete_service_provider_profiles
BEFORE DELETE ON public.service_provider_profiles
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX idx_spp_company ON public.service_provider_profiles(service_provider_company_id);
CREATE INDEX idx_spp_auth_user ON public.service_provider_profiles(auth_user_id);

-- ==========================================
-- Work Orders — Add Provider Columns
-- ==========================================
ALTER TABLE public.work_orders
  ADD COLUMN service_provider_company_id UUID NULL
    REFERENCES public.service_provider_companies(id) ON DELETE SET NULL,
  ADD COLUMN provider_profile_id UUID NULL
    REFERENCES public.service_provider_profiles(id) ON DELETE SET NULL,
  ADD COLUMN opened_by VARCHAR(20) NOT NULL DEFAULT 'internal'
    CONSTRAINT chk_opened_by CHECK (opened_by IN ('internal', 'provider'));

CREATE INDEX idx_work_orders_provider_company
  ON public.work_orders(company_id, service_provider_company_id);
