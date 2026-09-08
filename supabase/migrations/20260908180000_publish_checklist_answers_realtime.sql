-- ==============================================================================
-- Migration: Publish checklist_answers to realtime
-- ------------------------------------------------------------------------------
-- Templates and items have been on the publication since 20260905210000, so
-- configuration changes reach every device live. Answers were left off, so two
-- people executing the same work order never saw each other's answers and the
-- completion gate could disagree between their screens.
--
-- REPLICA IDENTITY FULL is already set by 20260906190000.
-- ==============================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'checklist_answers'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.checklist_answers;
  END IF;
END
$$;
