# sync_errors

Remote telemetry log for offline synchronization failures.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `user_id` | UUID | NO | - | FK → `user_profiles.id` (Cascade) |
| `entity_type` | VARCHAR(50) | NO | - | Type of entity (`work_order`, `observation`, `task`, `attachment`, `pause_request`) |
| `entity_id` | VARCHAR(100) | NO | - | ID of the target entity |
| `operation` | VARCHAR(50) | NO | - | Mutation operation (`create`, `update`, `delete`) |
| `payload` | JSONB | YES | - | JSON serialized payload of the failed request |
| `error_type` | VARCHAR(100) | NO | - | Error classification / exception type |
| `error_message` | TEXT | NO | - | Error message or failure details |
| `attempts` | INT | NO | 1 | Number of retry attempts made before logging |

## Deletion Rules

* **Hard Deletes**: Prohibited by the general `prevent_delete()` trigger.
* **Soft Deletes**: Standard soft delete supported via `deleted_at`.
