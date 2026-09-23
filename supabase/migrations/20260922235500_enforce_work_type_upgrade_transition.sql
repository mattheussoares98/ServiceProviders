-- Enforce company work_type upgrade transitions:
-- Allowed transitions:
--   internal_only -> hybrid
--   service_provider_only -> hybrid
-- Any downgrade or cross-single transition (e.g. internal_only -> service_provider_only, or hybrid -> internal_only) is rejected.

CREATE OR REPLACE FUNCTION public.enforce_company_work_type_transition()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.work_type IS DISTINCT FROM OLD.work_type THEN
    IF NOT (
      (OLD.work_type = 'internal_only' AND NEW.work_type = 'hybrid') OR
      (OLD.work_type = 'service_provider_only' AND NEW.work_type = 'hybrid')
    ) THEN
      RAISE EXCEPTION 'Transição de modelo de operação inválida de "%" para "%". Apenas upgrades para híbrido são permitidos.',
        OLD.work_type, NEW.work_type;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_enforce_company_work_type_transition ON public.companies;
CREATE TRIGGER tr_enforce_company_work_type_transition
  BEFORE UPDATE ON public.companies
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_company_work_type_transition();
