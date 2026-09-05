---
trigger: model_decision
description: Specialist for Supabase backend infrastructure, including PostgreSQL schema design, SQL migrations, RLS security policies, and Deno Edge Functions
---

# Database — ServicePro (Supabase)

## Rules
- ❌ No secrets in plain text. No production deletes without confirmation.
- ✅ Migrations live in `supabase/migrations/{YYYYMMDDHHMMSS}_{description}.sql`. Edge Functions in `supabase/functions/{name}/`.
- ✅ `snake_case` names. `VARCHAR(N)` for all text. `public.has_permission(key)` in every RLS/RPC.
- ✅ Remediation step for every security advisor flag.

## Delete Protection

Every table needs both hard and soft delete protection.

**Hard delete** — always block:
```sql
CREATE TRIGGER tr_prevent_delete_{table}
BEFORE DELETE ON public.{table}
FOR EACH ROW EXECUTE FUNCTION public.prevent_delete();
```

**Soft delete** — block if `deleted_at` + referenced by active records:
```sql
CREATE OR REPLACE FUNCTION public.check_{table}_before_delete() RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    IF EXISTS (SELECT 1 FROM public.{child} WHERE {fk} = OLD.id AND {activity_condition}) THEN
      RAISE EXCEPTION '...'; -- Portuguese
    END IF;
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER tr_prevent_delete_{table}_with_relations
  BEFORE UPDATE ON public.{table} FOR EACH ROW EXECUTE FUNCTION public.check_{table}_before_delete();
```

**Activity conditions:**
| Child | Condition |
|---|---|
| `work_orders` | `status != 'completed' AND deleted_at IS NULL` |
| `work_order_pause_requests` | `resumed_at IS NULL AND status IN ('pending', 'approved')` |
| `user_profiles` | any FK reference exists |

**Implemented:**
| Table | Protected against |
|---|---|
| `locations` | active assets + work orders |
| `assets` | active work orders |
| `categories` | active assets/checklists |
| `service_provider_companies` | active work orders |
| `sla_policies` | active work orders |
| `user_profiles` | active work orders (`assigned_to_id`) |
| `pause_reasons` | active pause requests |
| `sectors` | active pause requests |

## FK Design
- ❌ No `ON DELETE CASCADE` on business entities (only strict ownership like `companies → user_profiles`).
- ✅ `ON DELETE SET NULL` for nullable FKs; `ON DELETE RESTRICT` for non-nullable.

## Model/Schema Sync
- ✅ Keep Flutter `toJson`/`fromJson` and Drift table in sync with every migration.

## Table & Migration Checklist
- [ ] `BEFORE DELETE` trigger (hard delete prevention)
- [ ] RLS: SELECT / INSERT / UPDATE / DELETE policies
- [ ] Soft-delete `BEFORE UPDATE` trigger (if `deleted_at` + FK to active records)
- [ ] Drift table updated (`lib/core/clients/local/drift/tables/`) & `AppDatabase` schema version bumped
- [ ] Flutter models updated (`fromJson` / `toJson` / `fromEntity` / `toEntity`)
- [ ] `docs/schema/{table}.md` updated (or created) + `index.md` ERD/table list updated
- [ ] `docs/database_rules/{table}_rules.md` updated (or created) and linked in `docs/database_rules/global_rules.md` §3

## Tools (Supabase MCP)
`list_tables` before any schema change · `apply_migration` for DDL · `execute_sql` for inspection/data · `get_advisors` for security checks.
Without the MCP server connected, write the migration file and ask the user to apply it.

## Documentation — MANDATORY, same response as the change

❌ Never defer. Update docs in the same turn as the migration.

**Order:**
1. Run migration (`apply_migration` / `execute_sql`).
2. `docs/schema/{table}.md` — update column row (ALTER) or create file (CREATE).
3. `docs/database_rules/{table}_rules.md` — update/create with current policy SQL and triggers.
4. Link new rules file in `docs/database_rules/global_rules.md` §3 (if new table).
5. New table only: update `docs/schema/index.md` (ERD + table index).

> Common columns (`id`, `company_id`, `created_at`, `updated_at`, `deleted_at`) documented only in `index.md`.