-- Add resumed_by_id to work_order_pause_requests for complete pause audit trail
ALTER TABLE public.work_order_pause_requests
  ADD COLUMN IF NOT EXISTS resumed_by_id UUID NULL REFERENCES auth.users(id) ON DELETE SET NULL;

-- Update RLS policy for updating pause requests (allow updating resumed_at and resumed_by_id for active pending requests)
DROP POLICY IF EXISTS "Users update work order pause requests" ON public.work_order_pause_requests;

CREATE POLICY "Users update work order pause requests"
  ON public.work_order_pause_requests FOR UPDATE
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND public.has_permission('work_orders.approve_pause')
    )
    OR (
      requested_by_id = auth.uid()
      AND status = 'pending'
    )
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      JOIN public.service_provider_profiles spp ON wo.service_provider_company_id = spp.service_provider_company_id
      WHERE wo.id = work_order_id AND spp.auth_user_id = auth.uid()
      AND status = 'pending'
    )
  );
