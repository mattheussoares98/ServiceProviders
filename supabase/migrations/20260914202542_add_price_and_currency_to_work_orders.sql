-- ==============================================================================
-- Migration: Add price and currency to work_orders
-- ==============================================================================

-- 1. Add price and currency columns to work_orders
ALTER TABLE public.work_orders
  ADD COLUMN IF NOT EXISTS price NUMERIC(12, 2) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS currency VARCHAR(3) NOT NULL DEFAULT 'BRL';

COMMENT ON COLUMN public.work_orders.price IS
  'Contracted or billed price for the work order. Nullable, gated by manage_financials permission.';

COMMENT ON COLUMN public.work_orders.currency IS
  'ISO 4217 3-letter currency code (e.g. BRL). Defaults to BRL.';
