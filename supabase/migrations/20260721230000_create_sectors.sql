-- ==========================================
-- Sectors Table
-- ==========================================
CREATE TABLE IF NOT EXISTS public.sectors (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);

CREATE UNIQUE INDEX unique_sector_name_per_company_idx ON public.sectors (company_id, lower(trim(name))) WHERE deleted_at IS NULL;

ALTER TABLE public.sectors ENABLE ROW LEVEL SECURITY;

-- Read sectors: members of same company or service providers associated with company's work orders
CREATE POLICY "Users read own company sectors"
  ON public.sectors FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.service_provider_profiles spp
      JOIN public.service_provider_companies spc ON spp.service_provider_company_id = spc.id
      WHERE spp.auth_user_id = auth.uid() AND spc.company_id = public.sectors.company_id
    )
  );

-- Manage sectors: only company users with sectors.create/update/delete permissions
CREATE POLICY "Company users insert own company sectors with permission"
  ON public.sectors FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('sectors.create')
  );

CREATE POLICY "Company users update own company sectors with permission"
  ON public.sectors FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('sectors.update')
  );

CREATE TRIGGER tr_prevent_delete_sectors
BEFORE DELETE ON public.sectors
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX IF NOT EXISTS idx_sec_company ON public.sectors(company_id);

CREATE OR REPLACE FUNCTION public.check_sector_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    IF EXISTS (
      SELECT 1 
      FROM public.work_order_pause_requests 
      WHERE sector_id = OLD.id 
        AND resumed_at IS NULL 
        AND status IN ('pending', 'approved')
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir este setor porque ele possui solicitações de pausa ativas ou pendentes.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_prevent_delete_sectors_with_relations
  BEFORE UPDATE ON public.sectors
  FOR EACH ROW
  EXECUTE FUNCTION public.check_sector_before_delete();

-- Alter work_order_pause_requests: sector column becomes sector_id references public.sectors(id)
ALTER TABLE public.work_order_pause_requests 
  DROP COLUMN IF EXISTS sector;

ALTER TABLE public.work_order_pause_requests 
  ADD COLUMN sector_id UUID NULL REFERENCES public.sectors(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_wopr_sector ON public.work_order_pause_requests(sector_id);

-- Seed some default sectors for existing companies
INSERT INTO public.sectors (company_id, name)
SELECT id, 'Elétrica' FROM public.companies
UNION ALL
SELECT id, 'Hidráulica' FROM public.companies
UNION ALL
SELECT id, 'TI' FROM public.companies
UNION ALL
SELECT id, 'Mecânica' FROM public.companies;
