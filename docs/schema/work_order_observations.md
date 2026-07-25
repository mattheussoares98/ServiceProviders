# work_order_observations

Stores free-text timeline observations attached to a work order.

## Remote Schema (Supabase - PostgreSQL)

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | Primary Key |
| `company_id` | UUID | NO | — | Tenant FK -> `companies(id)` |
| `work_order_id` | UUID | NO | — | FK -> `work_orders(id)` |
| `author_id` | UUID | NO | — | FK -> `user_profiles(id)` |
| `content` | VARCHAR(2000) | NO | — | Observation message |
| `created_at` | TIMESTAMPTZ | NO | `now()` | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | Last update timestamp |
| `deleted_at` | TIMESTAMPTZ | YES | `NULL` | Soft delete timestamp |

---

## Local Schema (Drift - SQLite)

Table name: `work_order_observations_table`

| Column | Drift Type | Description |
|---|---|---|
| `id` | `TextColumn` | Primary key |
| `company_id` | `TextColumn` | Tenant ID |
| `work_order_id` | `TextColumn` | Work Order ID |
| `author_id` | `TextColumn` | Author profile ID |
| `author_name` | `TextColumn` | Cached author display name |
| `content` | `TextColumn` | Observation text |
| `created_at` | `DateTimeColumn` | Creation timestamp |
| `updated_at` | `DateTimeColumn` | Update timestamp |
| `deleted_at` | `DateTimeColumn` (nullable) | Soft delete timestamp |
