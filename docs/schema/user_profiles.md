# user_profiles

Extended profile mapping to Supabase Auth uid.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(255) | NO | - | Display name |
| `email` | VARCHAR(255) | NO | - | User email |
| `phone` | VARCHAR(30) | YES | - | Contact number |
| `permission_group_id` | UUID | YES | - | FK → `permission_groups.id` (Set Null) |
| `avatar_url` | VARCHAR(2048) | YES | - | Avatar image URL |
| `is_active` | BOOLEAN | NO | true | Active status |
| `is_admin` | BOOLEAN | NO | false | Admin privileges flag |

**Note**: `id` matches Supabase Auth uid.
