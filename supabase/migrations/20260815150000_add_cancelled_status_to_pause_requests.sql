-- ==============================================================================
-- Add 'cancelled' status to work_order_pause_requests & update sync trigger
-- ==============================================================================

-- 1. Update check constraint to allow 'cancelled'
ALTER TABLE public.work_order_pause_requests
  DROP CONSTRAINT IF EXISTS chk_status;

ALTER TABLE public.work_order_pause_requests
  ADD CONSTRAINT chk_status
  CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled', 'cancelled_by_provider'));

-- 2. Update trigger function to handle 'cancelled' status
CREATE OR REPLACE FUNCTION public.handle_work_order_pause_request_sync()
RETURNS TRIGGER AS $$
BEGIN
  -- When a new pause / completion request is created
  IF (TG_OP = 'INSERT') THEN
    IF NEW.status = 'pending' THEN
      IF NEW.event_type = 'completion' THEN
        UPDATE public.work_orders 
        SET status = 'pending_conclusion', updated_at = NOW() 
        WHERE id = NEW.work_order_id;
      ELSIF NEW.event_type = 'pause' THEN
        UPDATE public.work_orders 
        SET status = 'pending_pause', updated_at = NOW() 
        WHERE id = NEW.work_order_id;
      END IF;
    END IF;

  -- When a request is reviewed / updated (approved, rejected, cancelled, resumed)
  ELSIF (TG_OP = 'UPDATE') THEN
    -- If review status changed to approved
    IF NEW.status = 'approved' AND (OLD.status IS DISTINCT FROM 'approved') THEN
      IF NEW.event_type = 'completion' THEN
        UPDATE public.work_orders 
        SET status = 'completed', 
            completed_at = NOW(), 
            completion_reason = COALESCE(NEW.custom_reason, NEW.reason),
            completion_sector_id = NEW.sector_id,
            completion_responsibility = NEW.responsibility,
            updated_at = NOW() 
        WHERE id = NEW.work_order_id;
      ELSIF NEW.event_type = 'pause' THEN
        UPDATE public.work_orders 
        SET status = 'on_hold', updated_at = NOW() 
        WHERE id = NEW.work_order_id;
      END IF;

    -- If review status changed to rejected or cancelled
    ELSIF NEW.status IN ('rejected', 'cancelled', 'cancelled_by_provider') AND (OLD.status NOT IN ('rejected', 'cancelled', 'cancelled_by_provider')) THEN
      UPDATE public.work_orders 
      SET status = 'in_progress', updated_at = NOW() 
      WHERE id = NEW.work_order_id;

    -- If a pause is resumed
    ELSIF NEW.resumed_at IS NOT NULL AND OLD.resumed_at IS NULL THEN
      UPDATE public.work_orders 
      SET status = 'in_progress', updated_at = NOW() 
      WHERE id = NEW.work_order_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Fix UPDATE RLS policy with explicit WITH CHECK to allow status transitions
DROP POLICY IF EXISTS "Users update work order pause requests" ON public.work_order_pause_requests;

CREATE POLICY "Users update work order pause requests"
  ON public.work_order_pause_requests FOR UPDATE
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND (
        public.has_permission('work_orders.approve_pause')
        OR public.has_permission('work_orders.change_status')
        OR public.has_permission('work_orders.update')
      )
    )
    OR (
      requested_by_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      JOIN public.service_provider_profiles spp ON wo.service_provider_company_id = spp.service_provider_company_id
      WHERE wo.id = work_order_id AND spp.auth_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      WHERE wo.id = work_order_id AND wo.assigned_to_id = auth.uid()
    )
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      JOIN public.service_provider_profiles spp ON wo.service_provider_company_id = spp.service_provider_company_id
      WHERE wo.id = work_order_id AND spp.auth_user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.work_orders wo
      WHERE wo.id = work_order_id AND wo.assigned_to_id = auth.uid()
    )
  );

