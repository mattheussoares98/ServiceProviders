-- ==============================================================================
-- Migration: Add allow_provider_create_work_order to company_parameters and update RLS
-- ==============================================================================

-- 1. Add column allow_provider_create_work_order to company_parameters
ALTER TABLE public.company_parameters
  ADD COLUMN IF NOT EXISTS allow_provider_create_work_order BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN public.company_parameters.allow_provider_create_work_order IS
  'When enabled, service providers may open/create work orders directly for this company. Defaults to false.';

-- 2. Update RLS policy on work_orders FOR INSERT for providers
-- Requires that the contracting company has allow_provider_create_work_order = TRUE in company_parameters.
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
    AND EXISTS (
      SELECT 1 FROM public.company_parameters cp
      WHERE cp.company_id = work_orders.company_id
        AND cp.allow_provider_create_work_order = TRUE
        AND cp.deleted_at IS NULL
    )
  );
