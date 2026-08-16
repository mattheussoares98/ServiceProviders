-- ==============================================================================
-- Auto-sync Work Order status only from Completion Requests
-- Pause reviews no longer alter the Work Order status automatically
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
      END IF;
    ELSIF NEW.status = 'approved' THEN
      IF NEW.event_type = 'pause' THEN
        UPDATE public.work_orders 
        SET status = 'on_hold', updated_at = NOW() 
        WHERE id = NEW.work_order_id;
      END IF;
    END IF;

  -- When a request is reviewed / updated (approved, rejected)
  ELSIF (TG_OP = 'UPDATE') THEN
    -- If review status changed to approved for completion
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
      END IF;

    -- If review status changed to rejected for completion
    ELSIF NEW.status = 'rejected' AND (OLD.status IS DISTINCT FROM 'rejected') THEN
      IF NEW.event_type = 'completion' THEN
        UPDATE public.work_orders 
        SET status = 'in_progress', updated_at = NOW() 
        WHERE id = NEW.work_order_id;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
