CREATE OR REPLACE FUNCTION public.check_area_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    IF EXISTS (
      SELECT 1 
      FROM public.assets 
      WHERE area_id = OLD.id 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir esta área porque ela possui equipamentos ativos.';
    END IF;

    IF EXISTS (
      SELECT 1 
      FROM public.work_orders wo
      JOIN public.assets a ON wo.asset_id = a.id
      WHERE a.area_id = OLD.id 
        AND wo.status != 'completed' 
        AND wo.deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir esta área porque ela possui ordens de serviço ativas.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_prevent_delete_areas_with_relations
  BEFORE UPDATE ON public.areas
  FOR EACH ROW
  EXECUTE FUNCTION public.check_area_before_delete();
