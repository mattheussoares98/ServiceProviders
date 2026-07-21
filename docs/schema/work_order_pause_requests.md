# work_order_pause_requests

Tracks requests to pause the SLA clock and work on work orders.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `work_order_id` | UUID | NO | - | FK → `work_orders.id` (Cascade) |
| `requested_by_id` | UUID | YES | - | FK → `auth.users.id` (Set Null) - Requester user |
| `reason_id` | UUID | YES | - | FK → `pause_reasons.id` (Set Null) - Normalized pre-registered reason |
| `custom_reason` | VARCHAR(255) | YES | - | Free-text reason entered by the provider / requester |
| `observation` | TEXT | YES | - | Optional free-text observation from requester |
| `responsibility` | VARCHAR(20) | NO | - | Responsibility: `provider` / `contractor` / `shared` |
| `sector` | VARCHAR(100) | YES | - | Responsible department or sector |
| `status` | VARCHAR(30) | NO | 'pending' | `pending` / `approved` / `rejected` / `cancelled_by_provider` |
| `paused_at` | TIMESTAMP | NO | now() | When the pause request was initiated |
| `resumed_at` | TIMESTAMP | YES | - | When the work resumed (unpaused) |
| `reviewed_by_id` | UUID | YES | - | FK → `auth.users.id` (Set Null) - Approver/rejecter |
| `review_observation` | TEXT | YES | - | Optional review comment from approver |
| `affects_sla` | BOOLEAN | NO | true | Whether this pause halts the SLA target clock |

