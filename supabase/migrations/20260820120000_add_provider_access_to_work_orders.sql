-- Grants service provider members read/update access to the work orders assigned
-- to their provider company, across every contracting company.
--
-- Before this migration the work_orders SELECT policy was scoped exclusively to
-- company_id = public.get_user_company_id(), so a provider-only user (who has no
-- user_profiles row) matched nothing, and a dual-identity user saw only their
-- employer's orders. work_order_pause_requests already carried a provider branch;
-- work_orders did not.

-- Returns true when the current auth user belongs to the provider company that
-- the given work order is assigned to. When the work order also names a specific
-- provider technician, only that technician matches.
CREATE OR REPLACE FUNCTION public.is_provider_member_of_work_order(
  p_service_provider_company_id UUID,
  p_provider_profile_id UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.service_provider_profiles spp
    WHERE spp.auth_user_id = auth.uid()
      AND spp.service_provider_company_id = p_service_provider_company_id
      AND spp.is_active
      AND (p_provider_profile_id IS NULL OR p_provider_profile_id = spp.id)
  );
$$;

COMMENT ON FUNCTION public.is_provider_member_of_work_order(UUID, UUID) IS
  'True when auth.uid() is an active member of the work order''s assigned provider company. If the work order names a specific provider_profile_id, only that profile matches.';

-- SELECT: keep the existing internal-employee branch untouched, add a provider branch.
DROP POLICY IF EXISTS "Users read own company work orders with permission" ON public.work_orders;
CREATE POLICY "Users read own company work orders with permission"
  ON public.work_orders FOR SELECT
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND (
        public.get_work_orders_read_scope() = 'all'
        OR (public.get_work_orders_read_scope() = 'assigned' AND assigned_to_id = auth.uid())
      )
    )
    OR public.is_provider_member_of_work_order(service_provider_company_id, provider_profile_id)
  );

-- UPDATE: providers execute work (status changes, timers, completion metadata) on
-- their own assigned orders. Scope checks still gate internal employees.
DROP POLICY IF EXISTS "Users update own company work orders with permission" ON public.work_orders;
CREATE POLICY "Users update own company work orders with permission"
  ON public.work_orders FOR UPDATE
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND (
        public.get_work_orders_update_scope() = 'all'
        OR (public.get_work_orders_update_scope() = 'assigned' AND assigned_to_id = auth.uid())
        OR (public.get_work_orders_update_scope() = 'own' AND created_by_id = auth.uid())
      )
    )
    OR public.is_provider_member_of_work_order(service_provider_company_id, provider_profile_id)
  )
  WITH CHECK (
    (
      company_id = public.get_user_company_id()
      AND (
        public.get_work_orders_update_scope() = 'all'
        OR (public.get_work_orders_update_scope() = 'assigned' AND assigned_to_id = auth.uid())
        OR (public.get_work_orders_update_scope() = 'own' AND created_by_id = auth.uid())
      )
    )
    OR public.is_provider_member_of_work_order(service_provider_company_id, provider_profile_id)
  );

-- Providers open work orders too (V2 §1.3 / Q5). opened_by = 'provider' identifies them.
DROP POLICY IF EXISTS "Providers insert work orders for their companies" ON public.work_orders;
CREATE POLICY "Providers insert work orders for their companies"
  ON public.work_orders FOR INSERT
  TO authenticated
  WITH CHECK (
    public.is_provider_member_of_work_order(service_provider_company_id, provider_profile_id)
  );

-- Helper to check provider company membership without triggering recursive RLS evaluation
CREATE OR REPLACE FUNCTION public.is_provider_member_of_company(p_service_provider_company_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.service_provider_profiles spp
    WHERE spp.service_provider_company_id = p_service_provider_company_id
      AND spp.auth_user_id = auth.uid()
      AND spp.is_active
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_provider_member_of_company(UUID) FROM anon;

-- Providers must be able to read the provider companies they belong to. The only
-- existing SELECT policy on service_provider_companies is scoped to
-- company_id = public.get_user_company_id(), which never matches a provider.
-- Without this the provider company filter renders no names.
DROP POLICY IF EXISTS "Provider users read their own provider companies" ON public.service_provider_companies;
CREATE POLICY "Provider users read their own provider companies"
  ON public.service_provider_companies FOR SELECT
  TO authenticated
  USING (
    public.is_provider_member_of_company(id)
  );

-- Supporting index: the provider branch filters on service_provider_company_id alone.
-- The existing idx_work_orders_provider_company leads with company_id, so it cannot
-- serve a provider query that spans companies.
CREATE INDEX IF NOT EXISTS idx_work_orders_service_provider_company_id
  ON public.work_orders (service_provider_company_id)
  WHERE deleted_at IS NULL;

-- ==========================================
-- Related tables the work order details page reads
-- ==========================================
-- Attachments and observations are both scoped to company_id, so a provider
-- opening one of their own work orders saw no photos and could not add a note —
-- despite V2 §4.1 / Q5 requiring exactly that. Both get the same provider branch,
-- keyed off the parent work order.

CREATE OR REPLACE FUNCTION public.is_provider_member_of_work_order_id(p_work_order_id UUID)
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
    WHERE wo.id = p_work_order_id
      AND spp.auth_user_id = auth.uid()
      AND spp.is_active
      AND (wo.provider_profile_id IS NULL OR wo.provider_profile_id = spp.id)
  );
$$;

-- Attachments
DROP POLICY IF EXISTS "Users read own company attachments with permission" ON public.attachments;
CREATE POLICY "Users read own company attachments with permission"
  ON public.attachments FOR SELECT
  TO authenticated
  USING (
    (company_id = public.get_user_company_id() AND public.has_permission('attachments.read'))
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );

DROP POLICY IF EXISTS "Users insert own company attachments with permission" ON public.attachments;
CREATE POLICY "Users insert own company attachments with permission"
  ON public.attachments FOR INSERT
  TO authenticated
  WITH CHECK (
    (company_id = public.get_user_company_id() AND public.has_permission('attachments.create'))
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );

-- Observations
DROP POLICY IF EXISTS "Users can view observations of their company" ON public.work_order_observations;
CREATE POLICY "Users can view observations of their company"
  ON public.work_order_observations FOR SELECT
  USING (
    company_id = public.get_user_company_id()
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );

DROP POLICY IF EXISTS "Users can insert observations into work orders of their company" ON public.work_order_observations;
CREATE POLICY "Users can insert observations into work orders of their company"
  ON public.work_order_observations FOR INSERT
  WITH CHECK (
    (
      company_id = public.get_user_company_id()
      AND (author_id = auth.uid() OR public.has_permission('work_orders.update'))
    )
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );

DROP POLICY IF EXISTS "Users can update observations of their company" ON public.work_order_observations;
CREATE POLICY "Users can update observations of their company"
  ON public.work_order_observations FOR UPDATE
  USING (
    (
      company_id = public.get_user_company_id()
      AND (
        author_id = auth.uid()
        OR public.has_permission('work_orders.delete_observation')
        OR public.has_permission('work_orders.update')
      )
    )
    OR (public.is_provider_member_of_work_order_id(work_order_id) AND author_id = auth.uid())
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );
