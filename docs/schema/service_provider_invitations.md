# service_provider_invitations

Stores pending and historical invitations issued to service provider companies.

## Remote Schema (Supabase - PostgreSQL)

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | Primary Key |
| `email` | VARCHAR(255) | NO | — | Target invitation email address |
| `service_provider_company_id` | UUID | NO | — | FK -> `service_provider_companies(id)` |
| `invite_token` | VARCHAR(64) | YES | NULL | Verification magic link token |
| `status` | VARCHAR(20) | NO | `'pending'` | Status (`pending`, `accepted`, `rejected`, `expired`) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | Creation timestamp |
| `accepted_at` | TIMESTAMPTZ | YES | NULL | Acceptance timestamp |
| `expires_at` | TIMESTAMPTZ | YES | NULL | Expiration timestamp |

---

## Local Schema (Drift - SQLite)

Table name: `service_provider_invitations_table`

| Column | Drift Type | Description |
|---|---|---|
| `id` | `TextColumn` | Primary key |
| `email` | `TextColumn` | Target invitation email |
| `service_provider_company_id` | `TextColumn` | FK -> `service_provider_companies.id` |
| `invite_token` | `TextColumn` (nullable) | Magic link verification token |
| `status` | `TextColumn` | Status string |
| `created_at` | `DateTimeColumn` | Creation timestamp |
| `accepted_at` | `DateTimeColumn` (nullable) | Acceptance timestamp |
| `expires_at` | `DateTimeColumn` (nullable) | Expiration timestamp |
