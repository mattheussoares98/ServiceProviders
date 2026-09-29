-- Migration: Rename companies.cnpj to document and update unique index
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'companies' AND column_name = 'cnpj' AND table_schema = 'public'
  ) THEN
    ALTER TABLE public.companies RENAME COLUMN cnpj TO document;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE tablename = 'companies' AND indexname = 'uq_companies_cnpj_active'
  ) THEN
    ALTER INDEX public.uq_companies_cnpj_active RENAME TO uq_companies_document_active;
  END IF;
END $$;
