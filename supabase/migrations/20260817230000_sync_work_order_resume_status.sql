-- ==============================================================================
-- Restore resumed_at synchronization to work_orders in handle_work_order_pause_request_sync
-- When a pause request's resumed_at is set, transition the work order to 'in_progress'
-- ==============================================================================

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
        SET status = 'on_hold', updated_at = NOW() 
        WHERE id = NEW.work_order_id;
      END IF;
    ELSIF NEW.status = 'approved' THEN
      IF NEW.event_type = 'pause' THEN
        UPDATE public.work_orders 
        SET status = 'on_hold', updated_at = NOW() 
        WHERE id = NEW.work_order_id;
      ELSIF NEW.event_type = 'completion' THEN
        UPDATE public.work_orders 
        SET status = 'completed', 
            completed_at = NOW(), 
            completion_reason = NEW.custom_reason,
            completion_sector_id = NEW.sector_id,
            completion_responsibility = NEW.responsibility,
            updated_at = NOW() 
        WHERE id = NEW.work_order_id;
      END IF;
    END IF;

  -- When a request is reviewed / updated (approved, rejected, resumed)
  ELSIF (TG_OP = 'UPDATE') THEN
    -- If review status changed to approved for completion
    IF NEW.status = 'approved' AND (OLD.status IS DISTINCT FROM 'approved') THEN
      IF NEW.event_type = 'completion' THEN
        UPDATE public.work_orders 
        SET status = 'completed', 
            completed_at = NOW(), 
            completion_reason = NEW.custom_reason,
            completion_sector_id = NEW.sector_id,
            completion_responsibility = NEW.responsibility,
            updated_at = NOW() 
        WHERE id = NEW.work_order_id;
      END IF;

    -- If review status changed to rejected for completion
    ELSIF NEW.status = 'rejected' AND (OLD.status IS DISTINCT FROM 'rejected') THEN
      IF NEW.event_type = 'completion' THEN
        UPDATE public.work_orders 
        SET status = 'in_progress', updated_at = NOW() 
        WHERE id = NEW.work_order_id;
      END IF;

    -- If a pause is resumed (resumed_at is set)
    ELSIF NEW.resumed_at IS NOT NULL AND OLD.resumed_at IS NULL THEN
      UPDATE public.work_orders 
      SET status = 'in_progress', updated_at = NOW() 
      WHERE id = NEW.work_order_id
        AND status = 'on_hold';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fix any work orders currently stuck in on_hold when their pause was already resumed
UPDATE public.work_orders wo
SET status = 'in_progress', updated_at = NOW()
WHERE wo.status = 'on_hold'
  AND EXISTS (
    SELECT 1 FROM public.work_order_pause_requests pr
    WHERE pr.work_order_id = wo.id
      AND pr.resumed_at IS NOT NULL
  )
  AND NOT EXISTS (
    SELECT 1 FROM public.work_order_pause_requests pr2
    WHERE pr2.work_order_id = wo.id
      AND pr2.event_type = 'pause'
      AND pr2.resumed_at IS NULL
      AND pr2.status NOT IN ('rejected', 'cancelled')
  );
