-- Migration: Add deleted_at to service_provider_companies
ALTER TABLE public.service_provider_companies
  ADD COLUMN deleted_at TIMESTAMP WITH TIME ZONE NULL;
