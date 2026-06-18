# maintenance_plans

Schedules defining automated work order generation.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `asset_id` | UUID | YES | - | FK → `assets.id` (Set Null) |
| `location_id` | UUID | YES | - | FK → `locations.id` (Set Null) |
| `title` | VARCHAR(255) | NO | - | Plan title |
| `description` | VARCHAR(2000) | YES | - | Detailed summary |
| `frequency` | VARCHAR(50) | NO | - | daily / weekly / biweekly / monthly etc. |
| `day_of_week` | INT | YES | - | Day index (1-7) for weekly |
| `day_of_month` | INT | YES | - | Day (1-31) for monthly |
| `month_of_year` | INT | YES | - | Month (1-12) for annual |
| `checklist_template_id` | UUID | YES | - | FK → `checklist_templates.id` (Set Null) |
| `assigned_to_id` | UUID | YES | - | FK → `user_profiles.id` (Set Null) |
| `priority` | VARCHAR(50) | NO | 'medium' | low / medium / high / critical |
| `is_active` | BOOLEAN | NO | true | Status toggle |
| `last_generated_at` | TIMESTAMP | YES | - | Last generation execution |
| `next_due_date` | TIMESTAMP | YES | - | Next predicted due date |
