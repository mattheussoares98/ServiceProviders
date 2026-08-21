-- Grants service provider members read access to the locations, areas and assets
-- referenced by the work orders assigned to their provider company.
--
-- Before this migration every one of those tables was scoped exclusively to
-- company_id = public.get_user_company_id(), which never matches a provider.
-- Two consequences on the work order details page in provider mode:
--   * location, area and asset labels rendered blank, because LocationsCubit and
--     AssetsCubit came back empty;
--   * getWorkOrderById joins `locations!inner`, so an RLS-filtered location made
--     the whole row disappear and the details page reported "not found" on reload.
--
-- Access is granted per work order, not per contracting company: a provider sees
-- only the rows its own assigned work orders point at. This is deliberately
-- narrower than the branches on sectors / sla_policies / pause_reasons, which key
-- off provider-company-to-company association alone.

-- ==========================================
-- Helpers
-- ==========================================
-- SECURITY DEFINER so that reading work_orders from inside a policy on another
-- table does not re-enter the work_orders RLS evaluation.

CREATE OR REPLACE FUNCTION public.is_provider_referenced_location(p_location_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.work_orders wo
    JOIN public.service_provider_profiles spp
      ON spp.service_provider_company_id = wo.service_provider_company_id
    WHERE wo.location_id = p_location_id
      AND wo.deleted_at IS NULL
      AND spp.auth_user_id = auth.uid()
      AND spp.is_active
      AND (wo.provider_profile_id IS NULL OR wo.provider_profile_id = spp.id)
  );
$$;

COMMENT ON FUNCTION public.is_provider_referenced_location(UUID) IS
  'True when the location is referenced by a work order assigned to a provider company auth.uid() actively belongs to.';

CREATE OR REPLACE FUNCTION public.is_provider_referenced_area(p_area_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.work_orders wo
    JOIN public.service_provider_profiles spp
      ON spp.service_provider_company_id = wo.service_provider_company_id
    WHERE wo.area_id = p_area_id
      AND wo.deleted_at IS NULL
      AND spp.auth_user_id = auth.uid()
      AND spp.is_active
      AND (wo.provider_profile_id IS NULL OR wo.provider_profile_id = spp.id)
  );
$$;

COMMENT ON FUNCTION public.is_provider_referenced_area(UUID) IS
  'True when the area is referenced by a work order assigned to a provider company auth.uid() actively belongs to.';

CREATE OR REPLACE FUNCTION public.is_provider_referenced_asset(p_asset_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.work_orders wo
    JOIN public.service_provider_profiles spp
      ON spp.service_provider_company_id = wo.service_provider_company_id
    WHERE wo.asset_id = p_asset_id
      AND wo.deleted_at IS NULL
      AND spp.auth_user_id = auth.uid()
      AND spp.is_active
      AND (wo.provider_profile_id IS NULL OR wo.provider_profile_id = spp.id)
  );
$$;

COMMENT ON FUNCTION public.is_provider_referenced_asset(UUID) IS
  'True when the asset is referenced by a work order assigned to a provider company auth.uid() actively belongs to.';

REVOKE EXECUTE ON FUNCTION public.is_provider_referenced_location(UUID) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.is_provider_referenced_area(UUID) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.is_provider_referenced_asset(UUID) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.is_provider_referenced_location(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_provider_referenced_area(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_provider_referenced_asset(UUID) TO authenticated;

-- ==========================================
-- Policies — internal branch kept verbatim, provider branch appended
-- ==========================================

DROP POLICY IF EXISTS "Users read own company locations with permission" ON public.locations;
CREATE POLICY "Users read own company locations with permission"
  ON public.locations FOR SELECT
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND public.has_permission('locations.read')
    )
    OR public.is_provider_referenced_location(id)
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
    OR public.is_provider_referenced_area(id)
  );

DROP POLICY IF EXISTS "Users read own company assets with permission" ON public.assets;
CREATE POLICY "Users read own company assets with permission"
  ON public.assets FOR SELECT
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND public.has_permission('assets.read')
    )
    OR public.is_provider_referenced_asset(id)
  );

-- ==========================================
-- Supporting indexes
-- ==========================================
-- The helpers probe work_orders by the referenced id alone; every existing index
-- on work_orders leads with company_id, so none of them can serve these lookups.
CREATE INDEX IF NOT EXISTS idx_work_orders_location_id
  ON public.work_orders (location_id)
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_work_orders_area_id
  ON public.work_orders (area_id)
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_work_orders_asset_id
  ON public.work_orders (asset_id)
  WHERE deleted_at IS NULL;
