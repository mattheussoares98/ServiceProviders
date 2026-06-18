# work_order_history

Audited tracking records capturing work order lifecycle updates.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `work_order_id` | UUID | NO | - | FK → `work_orders.id` (Cascade) |
| `user_id` | UUID | NO | - | FK → `user_profiles.id` (Cascade) |
| `action` | VARCHAR(100) | NO | - | Event classification (e.g. status_change) |
| `old_value` | VARCHAR(2000) | YES | - | Value prior to update |
| `new_value` | VARCHAR(2000) | YES | - | Value post update |

**Note**: No `updated_at` or `deleted_at`.
