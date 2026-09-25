# companies

Root multi-tenant table.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(255) | NO | - | Company name |
| `cnpj` | VARCHAR(14) | YES | - | Brazilian CNPJ or CPF (unique across active companies via `uq_companies_cnpj_active`) |
| `logo_url` | VARCHAR(2048) | YES | - | URL to company logo |
| `is_active` | BOOLEAN | NO | true | System status toggle |
| `plan_type` | VARCHAR(20) | NO | 'free' | Subscription tier: 'free' or 'paid' |
| `work_type` | VARCHAR(30) | NO | 'internal_only' | Operating mode: 'internal_only', 'service_provider_only', 'hybrid' |

**Note**: No `company_id` FK — this IS the root tenant table. Unique index `uq_companies_cnpj_active` enforces unique `cnpj` where `deleted_at IS NULL AND cnpj IS NOT NULL`.

