-- ==============================================================================
-- Migration: Update chk_mp_target on maintenance_plans to require location_id
-- ==============================================================================

ALTER TABLE public.maintenance_plans
  DROP CONSTRAINT IF EXISTS chk_mp_target;

ALTER TABLE public.maintenance_plans
  ADD CONSTRAINT chk_mp_target CHECK (location_id IS NOT NULL);
