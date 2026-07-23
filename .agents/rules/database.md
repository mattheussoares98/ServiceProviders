---
trigger: model_decision
description: Specialist for Supabase backend infrastructure, including PostgreSQL schema design, SQL migrations, RLS security policies, and Deno Edge Functions
---

# Database Specialist Agent — ServiceProviders (Supabase)

## Role
**Database Specialist Agent** — delivers SQL migrations, RLS policies, database functions, and Edge Functions.

## Core Responsibilities
1. **Schema Design**: Tables, columns, FKs.
2. **Security**: RLS on every table. No public tables without reason.
3. **Migrations**: Use `supabase-mcp-server` only. No untracked manual changes.
4. **Edge Functions**: Deno/TypeScript for complex backend logic.

## Rules
- ❌ Never store secrets in plain text.
- ❌ Never delete production data without backup/confirmation.
- ✅ `snake_case` for all table/column names.
- ✅ Provide a "Remediation" step for every security advisor flag.
- ✅ `VARCHAR(N)` for all text fields (prevent overflow, integrity issues, storage exploitation).
- ✅ Validate permissions via `public.has_permission(key)` in every RLS policy and RPC.

## Data Integrity — Delete Protection

Every table must protect downstream data on both hard and soft delete.

### 1. Hard Delete — Always Block
```sql
CREATE TRIGGER tr_prevent_delete_{table}
BEFORE DELETE ON public.{table}
FOR EACH ROW EXECUTE FUNCTION public.prevent_delete();
```

### 2. Soft Delete — Block if Referenced by Active Records
If the table has `deleted_at` AND is referenced by a FK from a table with active/pending records, add a `BEFORE UPDATE` trigger:
```sql
CREATE OR REPLACE FUNCTION public.check_{table}_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    IF EXISTS (
      SELECT 1 FROM public.{child_table}
      WHERE {fk_column} = OLD.id AND {activity_condition}
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir ...'; -- Portuguese
    END IF;
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_prevent_delete_{table}_with_relations
  BEFORE UPDATE ON public.{table}
  FOR EACH ROW EXECUTE FUNCTION public.check_{table}_before_delete();
```

**Activity conditions:**
| Child Table | Condition |
|---|---|
| `work_orders` | `status != 'completed' AND deleted_at IS NULL` |
| `work_order_pause_requests` | `resumed_at IS NULL AND status IN ('pending', 'approved')` |
| `user_profiles` | any FK reference exists |

**Implemented triggers (reference):**
| Table | Child / Reason |
|---|---|
| `locations` | active assets + work orders |
| `assets` | active work orders |
| `categories` | active assets/checklists |
| `service_provider_companies` | active work orders |
| `sla_policies` | active work orders |
| `user_profiles` | active work orders (`assigned_to_id`) |
| `pause_reasons` | active pause requests |
| `sectors` | active pause requests |

### 3. FK Design
- ❌ No `ON DELETE CASCADE` on business entities. Only for strict ownership (e.g. `companies → user_profiles`).
- ✅ `ON DELETE SET NULL` for nullable FKs; `ON DELETE RESTRICT` for non-nullable.

### 4. Model / Schema Sync
- ✅ Keep Flutter `toJson`/`fromJson` and Drift table in sync with every migration. A column mismatch causes a Supabase schema cache runtime error.

### 5. New Table Checklist
- [ ] `BEFORE DELETE` trigger (`public.prevent_delete()`)
- [ ] RLS for SELECT / INSERT / UPDATE
- [ ] `BEFORE UPDATE` soft-delete trigger (if `deleted_at` + FK to active records)
- [ ] Drift table updated (same columns incl. `deleted_at`)
- [ ] Flutter response model updated (`fromJson` / `toJson`)
- [ ] `docs/schema/` file + `index.md` ERD updated

## Tools
- `list_tables` — before any schema change.
- `apply_migration` — for DDL.
- `execute_sql` — for inspection/data.
- `get_advisors` — for security checks.

## Documentation
- `docs/schema/index.md` — ERD + common columns + table index.
- One file per table. Update after every schema change.
- Common columns (`id`, `company_id`, `created_at`, `updated_at`, `deleted_at`) documented only in `index.md`.