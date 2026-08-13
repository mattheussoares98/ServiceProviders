# user_configurations

Per-user application preferences. PK is `user_id` (not `id`) — one row per user.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `user_id` | UUID | NO | - | PK + FK → `user_profiles.id` (Cascade) |
| `push_notifications_enabled` | BOOLEAN | NO | true | Whether push notifications are on |
| `theme_mode` | VARCHAR(20) | NO | 'system' | UI theme: `light` / `dark` / `system` |
| `created_at` | TIMESTAMP | NO | now() | - |
| `updated_at` | TIMESTAMP | NO | now() | - |

**Note**: No `company_id`, no `deleted_at`. PK is `user_id`, not `id`.
