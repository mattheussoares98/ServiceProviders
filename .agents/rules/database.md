---
trigger: model_decision
description: Supabase schema, migrations, RLS, delete protection, and Edge Functions
---

# Database

Read the applicable Supabase skill and affected `docs/schema/` and `docs/database_rules/` files before database work. Preserve business protections; document justified exceptions rather than applying blanket rules to incompatible tables.

## Schema and security

- No plaintext secrets; production deletes require explicit confirmation.
- Use `snake_case`. Migrations: `supabase/migrations/<timestamp>_<description>.sql`; Edge Functions: `supabase/functions/<name>/`. Follow the skill's migration creation workflow.
- Project convention: bounded `VARCHAR(N)` for text. Authorization uses `public.has_permission(key)` for permission-controlled RLS/RPC operations; preserve documented auth/system exceptions.
- Enable RLS on exposed tables and verify role grants. Combine tenant/ownership checks with operation permissions; `has_permission` alone does not establish company ownership. Define policies for permitted operations; do not add an allow-delete policy when hard deletion is prohibited. Test both allowed and denied access, including cross-company attempts.
- New company triggers (`handle_new_company`) and default permission groups must use canonical client permission keys (`ResourceType.action` and scopes); sync trigger definitions alongside any permission schema changes.
- Edge Functions using service credentials must verify the caller and permitted tenant/action before privileged operations; keep service/R2 secrets server-side. Consult the Supabase skill for function/view security.
- No `ON DELETE CASCADE` on business entities except documented strict ownership (such as companies → user_profiles). Nullable FKs use `SET NULL`; non-nullable FKs use `RESTRICT`.

## Delete protection

Soft-deletable business tables block hard deletes with `public.prevent_delete()`. Preserve the documented `user_profiles` exception: `prevent_user_profile_delete()` permits pending-invitation revocation; never move that exception into the shared guard. Do not impose soft-delete columns on append-only or system tables without checking their lifecycle.

For tables with `deleted_at` and active dependents, add `check_<table>_before_delete()` and `tr_prevent_delete_<table>_with_relations` (`BEFORE UPDATE`). Reject the transition from null to non-null `deleted_at` when active references exist; use a pt-BR error.

Derive active-reference criteria from the affected table's lifecycle and latest migrations. Do not copy a global predicate: maintenance plans exclude both completed and cancelled work orders, while older guards differ. Preserve `deleted_by` attribution where supported. Hard removal from the local cache is not a remote business deletion.

## Migration workflow

1. Inspect the target schema (`list_tables` plus affected columns, constraints, triggers, policies, and grants) and confirm the intended project/environment from task context. Local migration files do not prove live deployment status; report when live inspection is unavailable.
2. Create/review the migration and update its docs in the same turn. Never apply anything during a plan-only task.
3. For authorized remote deployment, apply DDL with `apply_migration` in the same turn; use `execute_sql` for inspection or authorized data operations. Local development follows the skill's local migration workflow. If tools, authorization, or execution are blocked, retain the migration and clearly mark it unapplied with the next action. Never claim success or bypass an approval gate.
4. Verify the resulting behavior and run security advisors when available. Record remediation for every flag or a justified false positive.

Keep committed/deployed migration history intact; corrective changes use a new migration. For realtime-backed tables, verify publication/replica identity and client stream handling together, within authorized scope.

## Change checklist

- [ ] Required RLS, hard-delete protection, and applicable soft-delete checks verified.
- [ ] `docs/schema/<table>.md` and `docs/database_rules/<table>_rules.md` updated with authored changes and accurate deployment status.
- [ ] New tables linked in `docs/schema/index.md` (ERD/index) and `docs/database_rules/global_rules.md` §3. Common columns are documented only in the schema index.
- [ ] Affected Flutter JSON/entity mappings and Drift tables/schema version identified; update within authorized layer scope, or record the dependent step as pending. Do not claim end-to-end completion while required client updates remain.
