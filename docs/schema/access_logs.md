# access_logs

Immutable audit log of user access events (login, logout, token refresh) for security tracking and compliance.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK |
| `company_id` | UUID | NO | - | FK → `companies.id` (Cascade) |
| `user_id` | UUID | NO | - | FK → `user_profiles.id` (Cascade) |
| `action` | VARCHAR(50) | NO | - | Access event ('login', 'logout', 'app_access') |
| `ip_address` | VARCHAR(45) | YES | - | IPv4 / IPv6 client address |
| `device_info` | VARCHAR(255) | YES | - | Device OS / Client platform details |
| `created_at` | TIMESTAMPTZ | NO | `now()` | Timestamp of access event |

**Note**: Append-only log. No `updated_at` or `deleted_at`.
