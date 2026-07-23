-- Migration: Add unique constraint to document of service_provider_companies per company/tenant when active
CREATE UNIQUE INDEX service_provider_companies_company_document_active_idx
  ON public.service_provider_companies (company_id, document)
  WHERE deleted_at IS NULL;
