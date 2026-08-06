# work_orders

Instances of preventive, corrective, or inspection tasks.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `asset_id` | UUID | YES | - | FK → `assets.id` (Set Null) |
| `location_id` | UUID | NO | - | FK → `locations.id` (Cascade) |
| `area_id` | UUID | YES | - | FK → `areas.id` (Set Null) — must match `assets.area_id` when both are set |
| `assigned_to_id` | UUID | YES | - | FK → `user_profiles.id` (Set Null) |
| `created_by_id` | UUID | NO | - | FK → `user_profiles.id` (Cascade) |
| `maintenance_plan_id` | UUID | YES | - | FK → `maintenance_plans.id` (Set Null) |
| `title` | VARCHAR(255) | NO | - | Summary of issue/task |
| `description` | VARCHAR(2000) | YES | - | Details |
| `priority` | VARCHAR(50) | NO | 'medium' | low / medium / high / critical |
| `status` | VARCHAR(50) | NO | 'open' | open / in_progress / pending_pause / on_hold / pending_approval / completed / cancelled |
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
| `service_provider_company_id` | UUID | YES | - | FK → `service_provider_companies.id` (Set Null) |
| `provider_profile_id` | UUID | YES | - | FK → `service_provider_profiles.id` (Set Null) |
| `opened_by` | VARCHAR(20) | NO | 'internal' | Who opened: internal / provider |
| `sla_policy_id` | UUID | YES | - | FK → `sla_policies.id` (Set Null) |
| `sla_deadline_at` | TIMESTAMP | YES | - | SLA Target Deadline timestamp |
| `sla_breached` | BOOLEAN | NO | false | Whether SLA deadline was breached |
| `net_active_duration` | INT | YES | - | Total net active duration (excluding pauses) in minutes |
| `completion_reason` | VARCHAR(1000) | YES | - | Reason/justification provided upon completion |
| `completion_responsibility` | VARCHAR(20) | YES | - | Responsibility upon completion: `provider` / `contractor` / `shared` |
| `completion_sector_id` | UUID | YES | - | FK → `sectors.id` (Set Null) - Sector responsible for completion |


