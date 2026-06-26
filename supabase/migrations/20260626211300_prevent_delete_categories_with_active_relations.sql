CREATE OR REPLACE FUNCTION public.check_category_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    -- Check for active assets referencing this category
    IF EXISTS (
      SELECT 1 
      FROM public.assets 
      WHERE category_id = OLD.id 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir esta categoria porque ela possui equipamentos ativos.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_prevent_delete_categories_with_relations
  BEFORE UPDATE ON public.categories
  FOR EACH ROW
  EXECUTE FUNCTION public.check_category_before_delete();
