-- Phase 1: Maintenance Plans live-schema inventory.
-- Read-only: this script does not create, alter, update, or delete anything.
-- Run the complete script in the Supabase SQL Editor and return every result.

-- 1. Runtime and table existence / RLS state.
SELECT
  current_setting('server_version') AS postgres_version,
  to_regclass('public.maintenance_plans') AS maintenance_plans_table,
  to_regclass('public.work_orders') AS work_orders_table,
  (
    SELECT c.relrowsecurity
    FROM pg_catalog.pg_class AS c
    JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = 'maintenance_plans'
  ) AS rls_enabled,
  (
    SELECT c.relforcerowsecurity
    FROM pg_catalog.pg_class AS c
    JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = 'maintenance_plans'
  ) AS rls_forced,
  (
    SELECT c.relreplident
    FROM pg_catalog.pg_class AS c
    JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = 'maintenance_plans'
  ) AS replica_identity;

-- 2. Columns, defaults, identity/generated attributes, and nullability.
SELECT
  cols.ordinal_position,
  cols.column_name,
  cols.data_type,
  cols.udt_name,
  cols.character_maximum_length,
  cols.is_nullable,
  cols.column_default,
  cols.is_identity,
  cols.identity_generation,
  cols.is_generated,
  cols.generation_expression
FROM information_schema.columns AS cols
WHERE cols.table_schema = 'public'
  AND cols.table_name = 'maintenance_plans'
ORDER BY cols.ordinal_position;

-- 3. Primary key, unique, foreign-key, and check constraints.
SELECT
  con.conname AS constraint_name,
  con.contype AS constraint_type,
  pg_catalog.pg_get_constraintdef(con.oid, true) AS definition
FROM pg_catalog.pg_constraint AS con
JOIN pg_catalog.pg_class AS rel ON rel.oid = con.conrelid
JOIN pg_catalog.pg_namespace AS nsp ON nsp.oid = rel.relnamespace
WHERE nsp.nspname = 'public'
  AND rel.relname = 'maintenance_plans'
ORDER BY con.contype, con.conname;

-- 4. Index definitions.
SELECT
  indexname,
  indexdef
FROM pg_catalog.pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'maintenance_plans'
ORDER BY indexname;

-- 5. RLS policies, including USING and WITH CHECK expressions.
SELECT
  policyname,
  permissive,
  roles,
  cmd,
  qual AS using_expression,
  with_check AS with_check_expression
FROM pg_catalog.pg_policies
WHERE schemaname = 'public'
  AND tablename = 'maintenance_plans'
ORDER BY policyname;

-- 6. Explicit table grants relevant to the Data API.
SELECT DISTINCT
  grantee,
  privilege_type,
  is_grantable
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name = 'maintenance_plans'
  AND grantee IN ('anon', 'authenticated', 'service_role')
ORDER BY grantee, privilege_type;

-- 7. Non-internal triggers attached to maintenance_plans.
SELECT
  trg.tgname AS trigger_name,
  pg_catalog.pg_get_triggerdef(trg.oid, true) AS definition,
  proc_ns.nspname AS function_schema,
  proc.proname AS function_name
FROM pg_catalog.pg_trigger AS trg
JOIN pg_catalog.pg_class AS rel ON rel.oid = trg.tgrelid
JOIN pg_catalog.pg_namespace AS rel_ns ON rel_ns.oid = rel.relnamespace
JOIN pg_catalog.pg_proc AS proc ON proc.oid = trg.tgfoid
JOIN pg_catalog.pg_namespace AS proc_ns ON proc_ns.oid = proc.pronamespace
WHERE rel_ns.nspname = 'public'
  AND rel.relname = 'maintenance_plans'
  AND NOT trg.tgisinternal
ORDER BY trg.tgname;

-- 8. Foreign keys from work_orders to maintenance_plans.
SELECT
  con.conname AS constraint_name,
  pg_catalog.pg_get_constraintdef(con.oid, true) AS definition
FROM pg_catalog.pg_constraint AS con
JOIN pg_catalog.pg_class AS rel ON rel.oid = con.conrelid
JOIN pg_catalog.pg_namespace AS nsp ON nsp.oid = rel.relnamespace
WHERE nsp.nspname = 'public'
  AND rel.relname = 'work_orders'
  AND con.contype = 'f'
  AND pg_catalog.pg_get_constraintdef(con.oid, true) ILIKE '%maintenance_plan%'
ORDER BY con.conname;

-- 9. Realtime publication membership.
SELECT
  pubname,
  schemaname,
  tablename
FROM pg_catalog.pg_publication_tables
WHERE schemaname = 'public'
  AND tablename = 'maintenance_plans'
ORDER BY pubname;

-- 10. pg_cron availability. If cron_job_table is not null, also run the
-- optional query at the bottom of this file.
SELECT
  EXISTS (
    SELECT 1
    FROM pg_catalog.pg_extension
    WHERE extname = 'pg_cron'
  ) AS pg_cron_enabled,
  to_regclass('cron.job') AS cron_job_table;

-- 11. Existing functions that may already generate maintenance work orders.
SELECT
  proc_ns.nspname AS function_schema,
  proc.proname AS function_name,
  pg_catalog.pg_get_function_identity_arguments(proc.oid) AS arguments,
  pg_catalog.pg_get_function_result(proc.oid) AS result_type,
  proc.prosecdef AS security_definer,
  pg_catalog.pg_get_functiondef(proc.oid) AS definition
FROM pg_catalog.pg_proc AS proc
JOIN pg_catalog.pg_namespace AS proc_ns ON proc_ns.oid = proc.pronamespace
WHERE proc_ns.nspname NOT IN ('pg_catalog', 'information_schema')
  AND (
    proc.proname ILIKE '%maintenance%'
    OR proc.proname ILIKE '%generate%work%order%'
  )
ORDER BY proc_ns.nspname, proc.proname;

-- 12. OPTIONAL: existing rows summary without exposing business content.
-- Run only when section 1 reports maintenance_plans_table.
-- SELECT
--   count(*) AS total_rows,
--   count(*) FILTER (WHERE deleted_at IS NULL) AS active_rows,
--   count(*) FILTER (WHERE deleted_at IS NULL AND is_active) AS enabled_rows,
--   count(*) FILTER (
--     WHERE deleted_at IS NULL
--       AND is_active
--       AND next_due_date <= now()
--   ) AS currently_due_rows,
--   min(next_due_date) FILTER (WHERE deleted_at IS NULL AND is_active)
--     AS earliest_enabled_due_date,
--   max(updated_at) AS latest_update
-- FROM public.maintenance_plans;

-- OPTIONAL: run only when section 10 returns cron_job_table = cron.job.
-- Remove the leading comment markers and run this query separately.
-- SELECT
--   jobid,
--   schedule,
--   command,
--   nodename,
--   database,
--   username,
--   active,
--   jobname
-- FROM cron.job
-- WHERE command ILIKE '%maintenance%'
--    OR command ILIKE '%work_order%'
--    OR jobname ILIKE '%maintenance%'
-- ORDER BY jobid;
