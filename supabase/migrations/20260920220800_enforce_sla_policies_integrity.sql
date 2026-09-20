-- Migration: Enforce integrity on sla_policies table
-- 1. Ensure name is not empty or whitespace-only.
-- 2. Ensure target_hours is strictly positive.

ALTER TABLE public.sla_policies
    ADD CONSTRAINT chk_sla_policies_name_not_empty
    CHECK (length(trim(name)) > 0),
    ADD CONSTRAINT chk_sla_policies_target_hours_positive
    CHECK (target_hours > 0);
