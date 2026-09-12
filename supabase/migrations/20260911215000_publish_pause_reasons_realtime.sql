-- ==============================================================================
-- Migration: Publish pause_reasons to supabase_realtime
-- ------------------------------------------------------------------------------
-- Adds public.pause_reasons to the supabase_realtime publication so that creations,
-- updates, and soft deletions sync across devices in real time.
-- Sets REPLICA IDENTITY FULL so UPDATE / DELETE payloads include full records.
-- ==============================================================================

ALTER TABLE public.pause_reasons REPLICA IDENTITY FULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'pause_reasons'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.pause_reasons;
  END IF;
END
$$;
