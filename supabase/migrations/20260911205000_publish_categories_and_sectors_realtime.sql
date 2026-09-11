-- ==============================================================================
-- Migration: Publish categories and sectors to supabase_realtime
-- ------------------------------------------------------------------------------
-- Adds public.categories and public.sectors to the supabase_realtime publication
-- so that creations, updates, and soft deletions sync across devices in real time.
-- Sets REPLICA IDENTITY FULL so UPDATE / DELETE payloads include full records.
-- ==============================================================================

ALTER TABLE public.categories REPLICA IDENTITY FULL;
ALTER TABLE public.sectors REPLICA IDENTITY FULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'categories'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.categories;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'sectors'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.sectors;
  END IF;
END
$$;
