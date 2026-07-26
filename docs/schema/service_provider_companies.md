# service_provider_companies

Stores third-party service provider companies associated with a tenant company.

## Remote Schema (Supabase - PostgreSQL)

| Column | Type | Nullable | Default | Description |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | Primary Key |
| `company_id` | UUID | NO | — | Tenant FK -> `companies(id)` |
| `name` | VARCHAR(255) | NO | — | Company name |
| `document` | VARCHAR(14) | YES | NULL | CNPJ or CPF number |
| `document_type` | VARCHAR(4) | YES | NULL | Document type (`cpf` or `cnpj`) |
| `contact_email` | VARCHAR(255) | YES | NULL | Contact email address |
| `contact_phone` | VARCHAR(30) | YES | NULL | Contact phone number |
| `is_active` | BOOLEAN | NO | `true` | Active status flag |
| `created_at` | TIMESTAMPTZ | NO | `now()` | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | Last update timestamp |
| `deleted_at` | TIMESTAMPTZ | YES | `NULL` | Soft delete timestamp |

---

## Local Schema (Drift - SQLite)

Table name: `service_provider_companies_table`

| Column | Drift Type | Description |
|---|---|---|
| `id` | `TextColumn` | Primary key |
| `company_id` | `TextColumn` | Tenant FK -> `companies.id` |
| `name` | `TextColumn` | Provider company name |
| `document` | `TextColumn` (nullable) | CNPJ or CPF number |
| `document_type` | `TextColumn` (nullable) | Document type |
| `contact_email` | `TextColumn` (nullable) | Contact email |
| `contact_phone` | `TextColumn` (nullable) | Contact phone |
| `is_active` | `BoolColumn` | Active status |
| `created_at` | `DateTimeColumn` | Creation timestamp |
| `updated_at` | `DateTimeColumn` | Update timestamp |
| `deleted_at` | `DateTimeColumn` (nullable) | Soft delete timestamp |
