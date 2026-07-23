-- Migration: Prevent deleting service provider with active work orders
CREATE OR REPLACE FUNCTION public.check_service_provider_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    -- Check for active work orders linked to this service provider
    IF EXISTS (
      SELECT 1 
      FROM public.work_orders 
      WHERE service_provider_company_id = OLD.id 
        AND status != 'completed' 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir este prestador de serviço porque ele possui ordens de serviço ativas.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_prevent_delete_service_provider_companies_with_relations
  BEFORE UPDATE ON public.service_provider_companies
  FOR EACH ROW
  EXECUTE FUNCTION public.check_service_provider_before_delete();
