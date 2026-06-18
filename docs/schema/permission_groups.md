# permission_groups

Customizable, company-specific permission groups (replaces static roles).

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(100) | NO | - | Role name (e.g. Técnico, Gestor) |
| `permissions` | JSONB | NO | '[]' | List of permission codes |
| `is_default` | BOOLEAN | NO | false | System-provided group flag |

**Note**: No `updated_at`.
