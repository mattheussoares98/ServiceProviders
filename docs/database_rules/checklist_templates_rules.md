# checklist_templates — RLS Rules

RLS enabled. Templates are company configuration, so reads and writes are gated by the
`checklists.*` permission keys (present in the default permission groups since
`20260626231500_add_user_permissions_and_default_groups.sql`). Service providers never
author templates in a contracting company — they only read the checklist of an order
they execute, and their answers are gated by `checklist_answers` instead. See
[checklist_answers_rules.md](checklist_answers_rules.md).

## Delete protection

Hard delete is blocked by `tr_prevent_delete_checklist_templates`.

Soft delete is blocked while the template is still referenced by an open work order —
`work_orders.checklist_template_id` (added in
`20260908120000_add_checklist_template_to_work_orders.sql`):

```sql
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
```

Dropping the template from a work order uses `ON DELETE SET NULL`: losing the template
must never delete the order, and answers already recorded stay addressable by
`checklist_item_id`.
