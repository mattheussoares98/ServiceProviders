-- Create trigger function to cascade soft-delete from work orders to attachments
CREATE OR REPLACE FUNCTION public.handle_work_order_soft_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    UPDATE public.attachments
    SET deleted_at = NEW.deleted_at
    WHERE work_order_id = NEW.id;
  ELSIF NEW.deleted_at IS NULL AND OLD.deleted_at IS NOT NULL THEN
    UPDATE public.attachments
    SET deleted_at = NULL
    WHERE work_order_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to work_orders table
CREATE TRIGGER tr_work_order_soft_delete
  AFTER UPDATE OF deleted_at ON public.work_orders
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_work_order_soft_delete();

-- Enable pg_cron if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule the weekly cleanup job (Sunday at 3:00 AM)
-- Note: Replace '<project-ref>' with dynamic or env-based url if needed, or invoke locally via net.http_post
SELECT cron.schedule(
  'cleanup-deleted-attachments',
  '0 3 * * 0', -- 3:00 AM on Sunday
  $$ SELECT net.http_post(
       url := 'http://localhost:54321/functions/v1/cleanup-attachments',
       headers := '{"Content-Type": "application/json"}'::jsonb,
       body := '{}'::jsonb
     ) $$
);
