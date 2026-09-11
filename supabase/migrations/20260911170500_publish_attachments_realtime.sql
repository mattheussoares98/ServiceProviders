-- ==============================================================================
-- Migration: Publish attachments to supabase_realtime
-- ------------------------------------------------------------------------------
-- Adds public.attachments to the supabase_realtime publication so that live
-- attachment additions, updates, and soft deletions sync across devices.
-- Sets REPLICA IDENTITY FULL so UPDATE / DELETE payloads include full records.
-- ==============================================================================

ALTER TABLE public.attachments REPLICA IDENTITY FULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'attachments'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.attachments;
  END IF;
END
$$;
