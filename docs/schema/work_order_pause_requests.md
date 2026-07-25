# work_order_pause_requests

Tracks requests to pause work orders or request completion authorization (`event_type`: `pause` / `completion`). Used by supervisors/managers to review and approve/reject work order pause and completion workflows.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `work_order_id` | UUID | NO | - | FK → `work_orders.id` (Cascade) |
| `requested_by_id` | UUID | YES | - | FK → `auth.users.id` (Set Null) - Requester user |
| `event_type` | VARCHAR(20) | NO | 'pause' | Request type: `pause` (SLA pause request) / `completion` (completion approval request) |
| `reason_id` | UUID | YES | - | FK → `pause_reasons.id` (Set Null) - Normalized pre-registered reason |
| `custom_reason` | VARCHAR(255) | YES | - | Free-text reason entered by the provider / requester |
| `observation` | TEXT | YES | - | Optional free-text observation from requester |
| `responsibility` | VARCHAR(20) | NO | - | Responsibility: `provider` / `contractor` / `shared` |
| `sector_id` | UUID | YES | - | FK → `sectors.id` (Set Null) - Responsible department or sector |
| `status` | VARCHAR(30) | NO | 'pending' | `pending` / `approved` / `rejected` / `cancelled_by_provider` |
| `paused_at` | TIMESTAMP | NO | now() | When the pause or completion request was initiated |
| `resumed_at` | TIMESTAMP | YES | - | When the work resumed (unpaused) |
| `reviewed_by_id` | UUID | YES | - | FK → `auth.users.id` (Set Null) - Approver/rejecter |
| `review_observation` | TEXT | YES | - | Review comment or rejection reason from approver |
| `affects_sla` | BOOLEAN | NO | true | Whether this pause halts the SLA target clock |


