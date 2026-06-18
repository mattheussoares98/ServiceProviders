# work_orders

Instances of preventive, corrective, or inspection tasks.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `asset_id` | UUID | YES | - | FK → `assets.id` (Set Null) |
| `location_id` | UUID | NO | - | FK → `locations.id` (Cascade) |
| `assigned_to_id` | UUID | YES | - | FK → `user_profiles.id` (Set Null) |
| `created_by_id` | UUID | NO | - | FK → `user_profiles.id` (Cascade) |
| `maintenance_plan_id` | UUID | YES | - | FK → `maintenance_plans.id` (Set Null) |
| `title` | VARCHAR(255) | NO | - | Summary of issue/task |
| `description` | VARCHAR(2000) | YES | - | Details |
| `priority` | VARCHAR(50) | NO | 'medium' | low / medium / high / critical |
| `status` | VARCHAR(50) | NO | 'open' | open / in_progress / on_hold / completed |
| `type` | VARCHAR(50) | NO | 'corrective' | corrective / preventive / inspection |
| `scheduled_date` | TIMESTAMP | YES | - | Planned execution date |
| `started_at` | TIMESTAMP | YES | - | Work start time |
| `completed_at` | TIMESTAMP | YES | - | Work completion time |
| `estimated_duration` | INT | YES | - | Planned minutes |
| `actual_duration` | INT | YES | - | Total minutes spent |
| `labor_cost` | REAL | YES | - | Labor costs |
| `parts_cost` | REAL | YES | - | Parts cost |
| `total_cost` | REAL | YES | - | Total labor + parts |
| `notes` | VARCHAR(2000) | YES | - | Closing notes / technician remarks |
