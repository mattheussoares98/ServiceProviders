-- Migration: 20260925230000_enforce_companies_cnpj_unique_active.sql
-- Description: Enforce unique CNPJ/CPF across active (non-deleted) companies.

CREATE UNIQUE INDEX IF NOT EXISTS uq_companies_cnpj_active
ON public.companies (cnpj)
WHERE deleted_at IS NULL AND cnpj IS NOT NULL;
