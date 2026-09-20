-- Enforce non-empty title for maintenance_plans
ALTER TABLE maintenance_plans
  ADD CONSTRAINT chk_maintenance_plans_title_not_empty
  CHECK (length(trim(title)) > 0);
