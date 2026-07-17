# V2 Feature Roadmap — Partner Review Session

This document organizes the features discussed during the partner review session (building expert). All items are grouped by theme and cross-referenced with the existing schema.

---

## 1. Service Provider (Fornecedor) Management

### 1.1 Register Service Providers
A dedicated **service provider** entity (distinct from internal `user_profiles`). A service provider is an **external company or individual** contracted to execute work orders.

**New table: `service_providers`**
| Column | Type | Description |
|---|---|---|
| `company_id` | UUID | Tenant FK |
| `name` | VARCHAR(255) | Provider name |
| `cnpj` | VARCHAR(14) | Brazilian CNPJ (optional) |
| `contact_name` | VARCHAR(255) | Main contact person |
| `contact_email` | VARCHAR(255) | Email |
| `contact_phone` | VARCHAR(30) | Phone |
| `is_active` | BOOLEAN | Active status |

### 1.2 Assign Responsible Company to a Work Order
Extend `work_orders` with a `service_provider_id` FK column so that an external service provider can be designated as the responsible party.

**`work_orders` addition:** `service_provider_id UUID? → service_providers.id (Set Null)`

### 1.3 Provider-Initiated Work Orders
Service providers must be able to open their own work orders (tickets). A `opened_by` column differentiates who created the ticket.

**`work_orders` addition:** `opened_by VARCHAR(20)` → `'internal'` | `'provider'`

---

## 2. SLA (Service Level Agreement)

### 2.1 SLA Definition
SLAs apply to **both** the service provider AND the contracting company. Each SLA has a deadline in hours.

**New table: `sla_policies`**
| Column | Type | Description |
|---|---|---|
| `company_id` | UUID | Tenant FK |
| `name` | VARCHAR(100) | e.g. "SLA Urgente", "SLA Padrão" |
| `target_hours` | INT | Max hours to resolve |
| `applies_to` | VARCHAR(20) | `'provider'` \| `'contractor'` \| `'both'` |
| `priority_level` | VARCHAR(50) | low / medium / high / critical |

**`work_orders` additions:**
| Column | Type | Description |
|---|---|---|
| `sla_policy_id` | UUID? | FK → `sla_policies.id` (Set Null) |
| `sla_deadline_at` | TIMESTAMP? | Calculated: `created_at + target_hours` |
| `sla_breached` | BOOLEAN | `false` default, `true` when exceeded |
| `net_active_duration` | INT? | Minutes "running" (excludes valid pauses) |

### 2.2 Time-on-Hold Tracking
Total elapsed time and net active time are tracked separately. Every pause/resume event is logged in `work_order_history`. The SLA clock is paused or running depending on the pause classification result (see §3.2).

---

## 3. Pause / Completion Approval Workflow

### 3.1 Pause Request with Justification
When a service provider or technician requests to **pause** a work order, they must provide:
1. A **reason** (free-text or predefined list).
2. **Responsibility**: `'provider'` | `'contractor'` | `'shared'`.
3. A **department/sector** (`setor`).

The request enters `pending_pause` state — a supervisor/manager must **approve or reject** it.

### 3.2 Pause Approval Impact on SLA
| Approval result | SLA Impact |
|---|---|
| Approved + responsibility = `'contractor'` | Provider's SLA clock **paused** |
| Approved + responsibility = `'provider'` | SLA clock continues against provider |
| Rejected | Provider notified; must resume immediately |

### 3.3 Completion Pending Authorization
When a service provider marks a work order **completed**, status enters `pending_approval`. A supervisor/manager must:
- **Approve** → status becomes `completed`.
- **Reject** → status returns to `in_progress` with a rejection reason.

**Extended `work_orders.status` values:**
`open` / `in_progress` / `pending_pause` / `on_hold` / `pending_approval` / `completed` / `cancelled`

### 3.4 Pause Request Table

**New table: `work_order_pause_requests`**
| Column | Type | Description |
|---|---|---|
| `work_order_id` | UUID | FK → `work_orders.id` (Cascade) |
| `requested_by_id` | UUID | FK → `user_profiles.id` |
| `event_type` | VARCHAR(20) | `'pause'` \| `'completion'` |
| `reason` | VARCHAR(1000) | Free-text justification |
| `responsibility` | VARCHAR(20) | `'provider'` \| `'contractor'` \| `'shared'` |
| `sector` | VARCHAR(255) | Department/sector |
| `status` | VARCHAR(20) | `'pending'` \| `'approved'` \| `'rejected'` |
| `reviewed_by_id` | UUID? | FK → `user_profiles.id` (Set Null) |
| `affects_sla` | BOOLEAN? | Set on approval: does this pause count in SLA? |
| `paused_at` | TIMESTAMP | When pause was requested |
| `resumed_at` | TIMESTAMP? | When work resumed |

---

## 4. Observations & Pending Notifications

### 4.1 Observations
Allow internal users and providers to add free-text observations at any point (e.g., "Faltando material X para continuar").

**New table: `work_order_observations`**
| Column | Type | Description |
|---|---|---|
| `work_order_id` | UUID | FK → `work_orders.id` (Cascade) |
| `author_id` | UUID | FK → `user_profiles.id` |
| `content` | VARCHAR(2000) | Observation text |
| `is_pending` | BOOLEAN | `true` if this creates a pending action |
| `resolved_at` | TIMESTAMP? | When the pendency was resolved |
| `resolved_by_id` | UUID? | Who resolved it |

### 4.2 Pendency Notifications
When `is_pending = true`, the system fires a **FCM push notification** to the responsible party (assigned technician, supervisor, or provider contact), alerting them of the open pendency.

---

## 5. Escalation Engine

### 5.1 Escalation Policy
If a work order is not progressed within a configurable time window, notifications escalate automatically through the organizational hierarchy.

**New table: `escalation_policies`**
| Column | Type | Description |
|---|---|---|
| `company_id` | UUID | Tenant FK |
| `name` | VARCHAR(100) | Policy name |
| `trigger_after_minutes` | INT | Minutes of inactivity before triggering |
| `escalation_order` | JSONB | Ordered list of roles/user_ids to notify |

**Example `escalation_order`:**
```json
[
  { "level": 1, "role": "supervisor", "delay_minutes": 0 },
  { "level": 2, "role": "manager", "delay_minutes": 60 },
  { "level": 3, "role": "admin", "delay_minutes": 120 }
]
```

**`work_orders` additions:**
| Column | Type | Description |
|---|---|---|
| `escalation_policy_id` | UUID? | FK → `escalation_policies.id` (Set Null) |
| `last_escalation_level` | INT? | Current escalation level reached |
| `last_escalation_at` | TIMESTAMP? | When last escalation was triggered |

### 5.2 Escalation Engine Runtime
The engine runs as a **Supabase Edge Function** triggered by a `pg_cron` job every N minutes, querying overdue work orders and dispatching FCM notifications.

---

## 6. Completion & Pause Metadata

On **every** pause or completion event, the actor must fill in:

| Field | Type | Options |
|---|---|---|
| `reason` | Text | Free-text |
| `responsibility` | Enum | `'provider'` \| `'contractor'` \| `'shared'` |
| `sector` | Text | e.g. "Elétrica", "Hidráulica", "TI" |

Pause metadata → stored in `work_order_pause_requests`.  
Completion metadata → stored as columns on `work_orders`:

**`work_orders` additions:**
| Column | Type | Description |
|---|---|---|
| `completion_reason` | VARCHAR(1000)? | Why it was closed |
| `completion_responsibility` | VARCHAR(20)? | `'provider'` \| `'contractor'` \| `'shared'` |
| `completion_sector` | VARCHAR(255)? | Department/sector |

---

## 7. Access Log

Track every user login event and significant access action for security and auditing.

**New table: `access_logs`**
| Column | Type | Description |
|---|---|---|
| `company_id` | UUID | Tenant FK |
| `user_id` | UUID | FK → `user_profiles.id` |
| `action` | VARCHAR(50) | `'login'` \| `'logout'` \| `'token_refresh'` |
| `ip_address` | VARCHAR(45) | Client IP (IPv4/IPv6) |
| `device_info` | VARCHAR(255)? | Platform/device string |
| `created_at` | TIMESTAMP | Event timestamp |

> [!NOTE]
> No `updated_at` or `deleted_at` — access logs are immutable, append-only records.

---

## 8. History Consultation by Period

The `work_order_history` table already exists. The enhancement is **date-range filtering** on the query/UI layer so users can filter history between two dates.

No schema changes required — query and UI feature only.

---

## 9. PMBOK 7 Reference

The PMBOK 7 (7th Edition) methodology is used as a **guideline reference** for how features like SLA management, escalation workflows, and stakeholder communication are designed. It is not a direct implementation task but should inform design decisions for notifications, reporting, and governance features.

Reference: https://github.com/pmistandards/pmbokguide

---

## Open Questions

> [!IMPORTANT]
> **Q1 — Provider Portal vs. Role:** Should service providers have their own login (separate auth flow) or be regular `user_profiles` with a specific permission group?

> [!IMPORTANT]
> **Q2 — SLA Scope:** Should SLA policies be tied to priority levels (e.g., critical=4h, medium=48h) or freely configurable per work order?

> [!IMPORTANT]
> **Q3 — Escalation Engine:** Should it run server-side via Supabase `pg_cron` or client-driven? Server-side is recommended for reliability.

> [!IMPORTANT]
> **Q4 — "Taxa de entrega":** Is this a performance KPI (% of work orders completed on time) shown in a dashboard, or a literal fee charged to the provider?

> [!IMPORTANT]
> **Q5 — "Tratativas do lado do cliente":** A dedicated UI section for the contracting company to manage their own actions/responses on a work order, separate from the provider's view?
