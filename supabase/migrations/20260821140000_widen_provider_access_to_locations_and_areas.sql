-- Widens the provider read branch on locations and areas from
-- "the rows my work orders already reference" to "every row of a contracting
-- company that hired my provider company".
--
-- Why: a provider opening a NEW work order (V2 §1.3 / Q5) has to browse the
-- registry before any work order exists, so the per-work-order grant added in
-- 20260821120000 cannot serve the create form. This mirrors the branch already
-- carried by sectors, sla_policies and pause_reasons.
--
-- ⚠️ Deliberate scope decision (2026-08-21): a provider now reads the contracting
-- company's ENTIRE location and area registry, including sites it has never
-- worked at. Accepted for now; revisit if a customer objects. `assets` is NOT
-- widened — equipment stays on the narrow per-work-order grant, and the provider
-- create form omits the asset field. See docs/cmms/internal_app_mode_plan.md.

-- True when auth.uid() is an active member of any provider company that the
-- given contracting company hired. SECURITY DEFINER so that reading
-- service_provider_companies from inside another table's policy does not
-- re-enter that table's own RLS.
CREATE OR REPLACE FUNCTION public.is_provider_of_company(p_company_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.service_provider_profiles spp
    JOIN public.service_provider_companies spc
      ON spc.id = spp.service_provider_company_id
    WHERE spp.auth_user_id = auth.uid()
      AND spp.is_active
      AND spc.is_active
      AND spc.company_id = p_company_id
  );
$$;

COMMENT ON FUNCTION public.is_provider_of_company(UUID) IS
  'True when auth.uid() is an active member of a provider company hired by the given contracting company.';

REVOKE EXECUTE ON FUNCTION public.is_provider_of_company(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_provider_of_company(UUID) TO authenticated;

DROP POLICY IF EXISTS "Users read own company locations with permission" ON public.locations;
CREATE POLICY "Users read own company locations with permission"
  ON public.locations FOR SELECT
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND public.has_permission('locations.read')
    )
    OR public.is_provider_of_company(company_id)
  );

DROP POLICY IF EXISTS "Users read own company areas with permission" ON public.areas;
CREATE POLICY "Users read own company areas with permission"
  ON public.areas FOR SELECT
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND public.has_permission('locations.read')
    )
    OR public.is_provider_of_company(company_id)
  );

-- The per-work-order helpers for these two tables are now subsumed by the
-- branch above: every work order carries the contracting company that the
-- provider is associated with. is_provider_referenced_asset stays in use.
DROP FUNCTION IF EXISTS public.is_provider_referenced_location(UUID);
DROP FUNCTION IF EXISTS public.is_provider_referenced_area(UUID);
