-- Migration: Set REPLICA IDENTITY FULL for realtime tables
-- Ensures DELETE and UPDATE payloads contain all columns (e.g. company_id) in the replication stream

ALTER TABLE public.work_orders REPLICA IDENTITY FULL;
ALTER TABLE public.locations REPLICA IDENTITY FULL;
ALTER TABLE public.areas REPLICA IDENTITY FULL;
ALTER TABLE public.assets REPLICA IDENTITY FULL;
ALTER TABLE public.sla_policies REPLICA IDENTITY FULL;
ALTER TABLE public.user_profiles REPLICA IDENTITY FULL;
ALTER TABLE public.service_provider_companies REPLICA IDENTITY FULL;
ALTER TABLE public.service_provider_profiles REPLICA IDENTITY FULL;
