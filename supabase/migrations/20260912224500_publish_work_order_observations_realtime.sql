-- ==============================================================================
-- Migration: Publish work_order_observations to supabase_realtime
-- ------------------------------------------------------------------------------
-- Adds public.work_order_observations to the supabase_realtime publication so that creations,
-- updates, and soft deletions sync across devices in real time.
-- Sets REPLICA IDENTITY FULL so UPDATE / DELETE payloads include full records.
-- ==============================================================================

ALTER TABLE public.work_order_observations REPLICA IDENTITY FULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'work_order_observations'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.work_order_observations;
  END IF;
END
$$;
