-- Migration: Enable Realtime for lookup tables related to work orders
-- Tables: locations, areas, assets, sla_policies, user_profiles, service_provider_companies, service_provider_profiles

ALTER PUBLICATION supabase_realtime ADD TABLE
  public.locations,
  public.areas,
  public.assets,
  public.sla_policies,
  public.user_profiles,
  public.service_provider_companies,
  public.service_provider_profiles;
