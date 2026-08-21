-- Lets a service provider author an observation on a work order assigned to them.
--
-- 20260820120000 added the provider branch to the work_order_observations RLS
-- policies, but the insert still died on the foreign key: author_id is
-- NOT NULL REFERENCES user_profiles(id), and a provider-only user has no
-- user_profiles row. Authorship now points at exactly one of the two identity
-- tables, and the policies enforce that a provider may only claim their own
-- service_provider_profiles row.

ALTER TABLE public.work_order_observations
  ALTER COLUMN author_id DROP NOT NULL;

ALTER TABLE public.work_order_observations
  ADD COLUMN IF NOT EXISTS author_provider_profile_id UUID
    REFERENCES public.service_provider_profiles(id) ON DELETE RESTRICT;

-- Exactly one author. Every pre-existing row carries author_id, so the
-- constraint validates against current data.
ALTER TABLE public.work_order_observations
  DROP CONSTRAINT IF EXISTS chk_work_order_observations_single_author;
ALTER TABLE public.work_order_observations
  ADD CONSTRAINT chk_work_order_observations_single_author
  CHECK (num_nonnulls(author_id, author_provider_profile_id) = 1);

CREATE INDEX IF NOT EXISTS idx_work_order_observations_author_provider_profile_id
  ON public.work_order_observations (author_provider_profile_id)
  WHERE author_provider_profile_id IS NOT NULL;

COMMENT ON COLUMN public.work_order_observations.author_provider_profile_id IS
  'Set when the observation was written from provider mode. Mutually exclusive with author_id.';

-- True when the given service provider profile belongs to the current auth user.
CREATE OR REPLACE FUNCTION public.is_own_provider_profile(p_provider_profile_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.service_provider_profiles spp
    WHERE spp.id = p_provider_profile_id
      AND spp.auth_user_id = auth.uid()
      AND spp.is_active
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_own_provider_profile(UUID) FROM anon;

COMMENT ON FUNCTION public.is_own_provider_profile(UUID) IS
  'True when the service provider profile belongs to auth.uid() and is active.';

-- INSERT: an internal employee writes as themselves; a provider writes as their
-- own provider profile and may not borrow an internal author_id.
DROP POLICY IF EXISTS "Users can insert observations into work orders of their company" ON public.work_order_observations;
CREATE POLICY "Users can insert observations into work orders of their company"
  ON public.work_order_observations FOR INSERT
  WITH CHECK (
    (
      company_id = public.get_user_company_id()
      AND author_provider_profile_id IS NULL
      AND (author_id = auth.uid() OR public.has_permission('work_orders.update'))
    )
    OR (
      public.is_provider_member_of_work_order_id(work_order_id)
      AND author_id IS NULL
      AND public.is_own_provider_profile(author_provider_profile_id)
    )
  );

-- UPDATE: unchanged for internal users. The provider branch now matches on the
-- provider profile instead of author_id, which is null for provider rows.
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
    OR (
      public.is_provider_member_of_work_order_id(work_order_id)
      AND public.is_own_provider_profile(author_provider_profile_id)
    )
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );
