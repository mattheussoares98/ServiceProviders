# work_order_change_requests

Proposed changes to finalized/closed work orders.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `work_order_id` | UUID | NO | - | FK → `work_orders.id` (Cascade) |
| `requested_by_id` | UUID | NO | - | FK → `user_profiles.id` (Cascade) |
| `change_type` | VARCHAR(50) | NO | - | add_task / add_attachment / update_notes etc. |
| `change_data` | JSONB | NO | - | Serialized edit request payload |
| `status` | VARCHAR(50) | NO | 'pending' | pending / approved / rejected |
| `reviewed_by_id` | UUID | YES | - | FK → `user_profiles.id` (Set Null) |
| `rejection_reason` | VARCHAR(1000) | YES | - | Rejection description |
