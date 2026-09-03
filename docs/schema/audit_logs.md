# audit_logs

Polymorphic tracking table capturing audit entries and lifecycle updates across entities.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `company_id` | UUID | NO | - | FK → `companies.id` (Cascade) |
| `entity_type` | VARCHAR(50) | NO | - | Target table/entity ('work_orders', 'attachments', etc.) |
| `entity_id` | UUID | NO | - | Target record UUID |
| `parent_entity_type` | VARCHAR(50) | YES | - | Parent entity classification (e.g. 'work_orders') |
| `parent_entity_id` | UUID | YES | - | Parent record UUID |
| `user_id` | UUID | YES | - | FK → `user_profiles.id` (Set Null) |
| `action` | VARCHAR(50) | NO | - | Event action ('created', 'updated', 'deleted', 'status_changed') |
| `diff` | JSONB | YES | - | Normalized change set `{ summary, changes: [...] }` |
| `metadata` | JSONB | YES | - | Context snapshots (e.g. `{ file_name, file_url }`) |

**Note**: No `updated_at` or `deleted_at`.
