# tasks

Subtasks/steps checklist inside a work_order.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `work_order_id` | UUID | NO | - | FK → `work_orders.id` (Cascade) |
| `title` | VARCHAR(255) | NO | - | Subtask title |
| `description` | VARCHAR(1000) | YES | - | Instruction detail |
| `is_completed` | BOOLEAN | NO | false | Complete toggle |
| `completed_at` | TIMESTAMP | YES | - | Completion timestamp |
| `completed_by_id` | UUID | YES | - | FK → `user_profiles.id` (Set Null) |
| `sort_order` | INT | NO | 0 | Positional sort index |
