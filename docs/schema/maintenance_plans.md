# maintenance_plans

Schedules defining automated work order generation.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `location_id` | UUID | YES | - | FK → `locations.id` (Set Null) |
| `asset_id` | UUID | YES | - | FK → `assets.id` (Set Null) |
| `area_id` | UUID | YES | - | FK → `areas.id` (Set Null) |
| `assigned_to_id` | UUID | YES | - | FK → `user_profiles.id` (Set Null) |
| `service_provider_company_id` | UUID | YES | - | FK → `service_provider_companies.id` (Set Null) |
| `checklist_template_id` | UUID | YES | - | FK → `checklist_templates.id` (Set Null) |
| `title` | VARCHAR(255) | NO | - | Plan title |
| `description` | VARCHAR(2000) | YES | - | Detailed summary |
| `priority` | VARCHAR(50) | NO | 'medium' | low / medium / high / critical |
| `price` | NUMERIC(12,2) | YES | - | Billed / contracted price |
| `currency` | VARCHAR(3) | NO | 'BRL' | ISO 4217 currency code |
| `interval_value` | INT | NO | 1 | Recurrence step multiplier (e.g. 15 for 15 days) |
| `interval_unit` | VARCHAR(20) | NO | 'months' | days / weeks / months / years |
| `lead_time_days` | INT | NO | 0 | Advance creation lead time in days (max 30) |
| `duration_days` | INT | NO | 1 | Planned conclusion timeframe in days |
| `day_of_week` | INT | YES | - | Day index (1-7) for weekly plans |
| `day_of_month` | INT | YES | - | Day (1-31) for monthly plans |
| `month_of_year` | INT | YES | - | Month (1-12) for annual plans |
| `is_active` | BOOLEAN | NO | true | Status toggle |
| `last_generated_at` | TIMESTAMP | YES | - | Timestamp of last work order generation |
| `last_generated_work_order_id` | UUID | YES | - | FK → `work_orders.id` (Set Null) |
| `last_error` | VARCHAR(1000) | YES | - | Last error message if generation failed |
| `next_due_date` | TIMESTAMP | YES | - | Next predicted due/execution date |
