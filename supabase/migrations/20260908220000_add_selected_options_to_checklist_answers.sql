-- ==============================================================================
-- Migration: Add selected_options to checklist_answers
-- ------------------------------------------------------------------------------
-- Supports multiple-choice questions (multi_selection checklist items) where
-- technicians can select more than one option.
-- ==============================================================================

ALTER TABLE public.checklist_answers
  ADD COLUMN IF NOT EXISTS selected_options TEXT[] NULL;
