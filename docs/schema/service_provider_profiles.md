# service_provider_profiles

Stores individual profiles/workers belonging to a service provider company.

## Remote Schema (Supabase - PostgreSQL)

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | Primary Key |
| `auth_user_id` | UUID | YES | NULL | Auth user FK -> `auth.users(id)` |
| `service_provider_company_id` | UUID | NO | — | FK -> `service_provider_companies(id)` |
| `name` | VARCHAR(255) | NO | — | Worker display name |
| `email` | VARCHAR(255) | NO | — | Worker email address |
| `phone` | VARCHAR(30) | YES | NULL | Worker phone number |
| `is_active` | BOOLEAN | NO | `true` | Active status flag |
| `created_at` | TIMESTAMPTZ | NO | `now()` | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | Last update timestamp |

---

## Local Schema (Drift - SQLite)

Table name: `service_provider_profiles_table`

| Column | Drift Type | Description |
|---|---|---|
| `id` | `TextColumn` | Primary key |
| `auth_user_id` | `TextColumn` (nullable) | Auth user ID link |
| `service_provider_company_id` | `TextColumn` | FK -> `service_provider_companies.id` |
| `name` | `TextColumn` | Worker name |
| `email` | `TextColumn` | Worker email |
| `phone` | `TextColumn` (nullable) | Worker phone |
| `is_active` | `BoolColumn` | Active status |
| `created_at` | `DateTimeColumn` | Creation timestamp |
| `updated_at` | `DateTimeColumn` | Update timestamp |
