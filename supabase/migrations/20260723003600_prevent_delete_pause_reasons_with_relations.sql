-- Migration: Prevent deleting pause reasons with active pause requests
CREATE OR REPLACE FUNCTION public.check_pause_reason_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    -- Check for active or pending pause requests referencing this reason
    IF EXISTS (
      SELECT 1 
      FROM public.work_order_pause_requests 
      WHERE reason_id = OLD.id 
        AND resumed_at IS NULL 
        AND status IN ('pending', 'approved')
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir este motivo de pausa porque ele possui solicitações de pausa ativas ou pendentes.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_prevent_delete_pause_reasons_with_relations
  BEFORE UPDATE ON public.pause_reasons
  FOR EACH ROW
  EXECUTE FUNCTION public.check_pause_reason_before_delete();
