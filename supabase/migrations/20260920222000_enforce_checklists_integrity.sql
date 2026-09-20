-- Enforce non-empty name for checklist_templates
ALTER TABLE checklist_templates
  ADD CONSTRAINT chk_checklist_templates_name_not_empty
  CHECK (length(trim(name)) > 0);

-- Enforce selection types to have options with at least one option, and non-empty label
ALTER TABLE checklist_items
  ADD CONSTRAINT chk_checklist_items_label_not_empty
  CHECK (length(trim(label)) > 0);

ALTER TABLE checklist_items
  ADD CONSTRAINT chk_checklist_items_selection_options
  CHECK (
    type NOT IN ('selection', 'multiSelection') OR
    (options IS NOT NULL AND jsonb_typeof(options) = 'array' AND jsonb_array_length(options) > 0)
  );
