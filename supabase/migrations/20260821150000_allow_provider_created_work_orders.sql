-- Lets a service provider open a work order for a contracting company that
-- hired them (V2 §1.3 / Q5).
--
-- 20260820120000 already added the provider INSERT branch, but the insert died
-- on the foreign key: created_by_id is NOT NULL REFERENCES user_profiles(id),
-- and a provider-only user has no user_profiles row. Authorship now points at
-- exactly one of the two identity tables, exactly as work_order_observations
-- does since 20260820140000.

ALTER TABLE public.work_orders
  ALTER COLUMN created_by_id DROP NOT NULL;

ALTER TABLE public.work_orders
  ADD COLUMN IF NOT EXISTS created_by_provider_profile_id UUID
    REFERENCES public.service_provider_profiles(id) ON DELETE RESTRICT;

-- Exactly one creator. Every pre-existing row carries created_by_id, so the
-- constraint validates against current data.
ALTER TABLE public.work_orders
  DROP CONSTRAINT IF EXISTS chk_work_orders_single_creator;
ALTER TABLE public.work_orders
  ADD CONSTRAINT chk_work_orders_single_creator
  CHECK (num_nonnulls(created_by_id, created_by_provider_profile_id) = 1);

CREATE INDEX IF NOT EXISTS idx_work_orders_created_by_provider_profile_id
  ON public.work_orders (created_by_provider_profile_id)
  WHERE created_by_provider_profile_id IS NOT NULL;

COMMENT ON COLUMN public.work_orders.created_by_provider_profile_id IS
  'Set when the work order was opened from provider mode. Mutually exclusive with created_by_id.';

-- True when the provider company was hired by the given contracting company.
-- Keeps a provider from stamping a tenant it has no relationship with.
CREATE OR REPLACE FUNCTION public.is_provider_company_of_company(
  p_service_provider_company_id UUID,
  p_company_id UUID
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.service_provider_companies spc
    WHERE spc.id = p_service_provider_company_id
      AND spc.company_id = p_company_id
      AND spc.is_active
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_provider_company_of_company(UUID, UUID) FROM anon;

COMMENT ON FUNCTION public.is_provider_company_of_company(UUID, UUID) IS
  'True when the service provider company is registered under the given contracting company.';

-- Internal employees keep their branch, now barred from claiming provider
-- authorship on a row they own.
DROP POLICY IF EXISTS "Users insert own company work orders with permission" ON public.work_orders;
CREATE POLICY "Users insert own company work orders with permission"
  ON public.work_orders FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.create')
    AND created_by_provider_profile_id IS NULL
  );

-- A provider opens the work order as its own provider profile, assigned to its
-- own provider company, under the tenant that hired it.
DROP POLICY IF EXISTS "Providers insert work orders for their companies" ON public.work_orders;
CREATE POLICY "Providers insert work orders for their companies"
  ON public.work_orders FOR INSERT
  TO authenticated
  WITH CHECK (
    public.is_provider_member_of_work_order(
      service_provider_company_id,
      provider_profile_id
    )
    AND public.is_provider_company_of_company(
      service_provider_company_id,
      company_id
    )
    AND created_by_id IS NULL
    AND public.is_own_provider_profile(created_by_provider_profile_id)
  );
