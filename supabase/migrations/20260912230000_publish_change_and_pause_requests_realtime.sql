-- ==============================================================================
-- Migration: Publish work_order_change_requests and work_order_pause_requests to supabase_realtime
-- ------------------------------------------------------------------------------
-- Adds public.work_order_change_requests and public.work_order_pause_requests
-- to the supabase_realtime publication so that live changes sync across devices.
-- Sets REPLICA IDENTITY FULL so UPDATE / DELETE payloads include full records.
-- ==============================================================================

ALTER TABLE public.work_order_change_requests REPLICA IDENTITY FULL;
ALTER TABLE public.work_order_pause_requests REPLICA IDENTITY FULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'work_order_change_requests'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.work_order_change_requests;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'work_order_pause_requests'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.work_order_pause_requests;
  END IF;
END
$$;
