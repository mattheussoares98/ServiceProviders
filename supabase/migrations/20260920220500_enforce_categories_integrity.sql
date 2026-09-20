-- Migration: Enforce integrity on categories table
-- 1. Ensure category name is not empty or whitespace-only.

ALTER TABLE public.categories
    ADD CONSTRAINT chk_categories_name_not_empty
    CHECK (length(trim(name)) > 0);
