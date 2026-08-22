# user_device_tokens

Stores FCM device tokens registered by users for push notification delivery. Linked directly to `auth.users.id` to support internal users, service providers, and dual-identity users across multiple devices.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | Primary Key |
| `user_id` | UUID | NO | - | FK → `auth.users.id` (Cascade) |
| `device_token` | VARCHAR(500) | NO | - | FCM Registration Token |
| `platform` | VARCHAR(20) | NO | - | Platform (`android`, `ios`, `web`) |
| `created_at` | TIMESTAMP | NO | `now()` | - |
| `updated_at` | TIMESTAMP | NO | `now()` | - |

**Constraints & Indexes**:
- `UNIQUE (user_id, device_token)`
- Index on `user_id`
- Index on `device_token`
