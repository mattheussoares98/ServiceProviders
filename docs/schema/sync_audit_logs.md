# sync_audit_logs

Audited records documenting synchronizer operations.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `user_profile_id` | UUID | NO | - | FK → `user_profiles.id` (Cascade) |
| `entity_type` | VARCHAR(100) | NO | - | Table name of synchronized model |
| `entity_id` | UUID | NO | - | Id of synchronized entity |
| `operation` | VARCHAR(50) | NO | - | insert / update / delete |
| `synced_at` | TIMESTAMP | NO | now() | Execution timestamp |

**Note**: No `updated_at` or `deleted_at`. Uses `synced_at` instead of `created_at`.
