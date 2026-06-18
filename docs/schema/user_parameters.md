# user_parameters

User configuration and notification preferences.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `user_profile_id` | UUID | NO | - | FK → `user_profiles.id` (Cascade, Unique) |
| `push_notifications_enabled` | BOOLEAN | NO | true | Push notifications preference |

**Note**: Uses `user_profile_id` instead of `company_id`.
