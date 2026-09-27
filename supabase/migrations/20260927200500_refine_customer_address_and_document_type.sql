-- Migration: Refine customers table - drop document_type and add structured address columns
ALTER TABLE public.customers 
  DROP CONSTRAINT IF EXISTS chk_customers_document_type;

ALTER TABLE public.customers 
  DROP COLUMN IF EXISTS document_type;

ALTER TABLE public.customers 
  ADD COLUMN IF NOT EXISTS number VARCHAR(50) NULL,
  ADD COLUMN IF NOT EXISTS complement VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS neighborhood VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS city VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS state VARCHAR(50) NULL,
  ADD COLUMN IF NOT EXISTS postal_code VARCHAR(20) NULL;
