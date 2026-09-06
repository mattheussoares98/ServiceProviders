-- ==============================================================================
-- Migration: Add deleted_at to work_order_pause_requests
-- ------------------------------------------------------------------------------
-- Adds soft delete support (deleted_at TIMESTAMP WITH TIME ZONE NULL) to
-- work_order_pause_requests, updates RLS SELECT policy to exclude soft-deleted
-- rows, attaches the standard hard-delete prevention trigger, and updates the
-- work order soft-delete cascade trigger to cascade soft delete to pause requests.
-- ==============================================================================

-- 1. Add deleted_at column
ALTER TABLE public.work_order_pause_requests
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE NULL;

-- 2. Update SELECT policy to exclude soft-deleted rows
DROP POLICY IF EXISTS "Users read own company work order pause requests" ON public.work_order_pause_requests;
CREATE POLICY "Users read own company work order pause requests"
  ON public.work_order_pause_requests FOR SELECT
  TO authenticated
  USING (
    deleted_at IS NULL
    AND (
      company_id = public.get_user_company_id()
      OR EXISTS (
        SELECT 1 FROM public.work_orders wo
        JOIN public.service_provider_profiles spp ON wo.service_provider_company_id = spp.service_provider_company_id
        WHERE wo.id = work_order_id AND spp.auth_user_id = auth.uid()
      )
    )
  );

-- 3. Hard delete prevention trigger
DROP TRIGGER IF EXISTS tr_prevent_delete_pause_requests ON public.work_order_pause_requests;
CREATE TRIGGER tr_prevent_delete_pause_requests
BEFORE DELETE ON public.work_order_pause_requests
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

-- 4. Update cascade soft delete from work orders to also soft delete pause requests
CREATE OR REPLACE FUNCTION public.handle_work_order_soft_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    UPDATE public.attachments
    SET deleted_at = NEW.deleted_at
    WHERE work_order_id = NEW.id;

    UPDATE public.work_order_pause_requests
    SET deleted_at = NEW.deleted_at
    WHERE work_order_id = NEW.id;
  ELSIF NEW.deleted_at IS NULL AND OLD.deleted_at IS NOT NULL THEN
    UPDATE public.attachments
    SET deleted_at = NULL
    WHERE work_order_id = NEW.id;

    UPDATE public.work_order_pause_requests
    SET deleted_at = NULL
    WHERE work_order_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
