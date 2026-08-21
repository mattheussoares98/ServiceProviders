# work_order_observations

Stores free-text timeline observations attached to a work order.

> Authorship points at exactly one of the two identity tables, enforced by
> `chk_work_order_observations_single_author`
> (`num_nonnulls(author_id, author_provider_profile_id) = 1`). A provider-only
> user has no `user_profiles` row, so provider observations are recorded through
> `service_provider_profiles` instead.

## Remote Schema (Supabase - PostgreSQL)

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | Primary Key |
| `company_id` | UUID | NO | — | Tenant FK -> `companies(id)` |
| `work_order_id` | UUID | NO | — | FK -> `work_orders(id)` |
| `author_id` | UUID | YES | `NULL` | FK -> `user_profiles(id)`. Internal author |
| `author_provider_profile_id` | UUID | YES | `NULL` | FK -> `service_provider_profiles(id)`. Provider mode author |
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
| `author_id` | `TextColumn` (nullable) | Internal author profile ID |
| `author_provider_profile_id` | `TextColumn` (nullable) | Provider author profile ID |
| `author_name` | `TextColumn` | Cached author display name |
| `content` | `TextColumn` | Observation text |
| `created_at` | `DateTimeColumn` | Creation timestamp |
| `updated_at` | `DateTimeColumn` | Update timestamp |
| `deleted_at` | `DateTimeColumn` (nullable) | Soft delete timestamp |
