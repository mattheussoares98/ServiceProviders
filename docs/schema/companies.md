# companies

Root multi-tenant table.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(255) | NO | - | Company name |
| `cnpj` | VARCHAR(14) | YES | - | Brazilian CNPJ |
| `logo_url` | VARCHAR(2048) | YES | - | URL to company logo |
| `is_active` | BOOLEAN | NO | true | System status toggle |

**Note**: No `company_id` FK — this IS the root tenant table.
