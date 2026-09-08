-- ==============================================================================
-- Migration: Link a work order to the checklist it must execute
-- ------------------------------------------------------------------------------
-- `checklist_answers` already keys answers by (work_order_id, checklist_item_id),
-- but nothing said *which* template a work order should answer. This adds the
-- explicit link so the execution screen can render the right checklist and the
-- completion flow can require its mandatory items.
--
-- SET NULL on delete: losing the template must not delete the work order, and
-- answers already recorded stay addressable by checklist_item_id.
-- ==============================================================================

ALTER TABLE public.work_orders
  ADD COLUMN IF NOT EXISTS checklist_template_id UUID NULL
    REFERENCES public.checklist_templates(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_work_orders_checklist_template
  ON public.work_orders(checklist_template_id)
  WHERE checklist_template_id IS NOT NULL;

-- A template still referenced by an open work order cannot be soft deleted.
CREATE OR REPLACE FUNCTION public.check_checklist_templates_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    IF EXISTS (
      SELECT 1 FROM public.work_orders wo
      WHERE wo.checklist_template_id = OLD.id
        AND wo.status != 'completed'
        AND wo.deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir um checklist vinculado a ordens de serviço em aberto.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_prevent_delete_checklist_templates_with_relations
  BEFORE UPDATE ON public.checklist_templates
  FOR EACH ROW
  EXECUTE FUNCTION public.check_checklist_templates_before_delete();
