# V2 Feature Roadmap — Partner Review Session

This document organizes the features discussed during the partner review session (building expert). All items are grouped by theme and cross-referenced with the existing schema.

---

## 1. Service Provider (Fornecedor) Management

### 1.1 Identity Architecture — Dual-Mode Model

A single Supabase Auth account (email + password) can hold two separate identities simultaneously:

- **Employee identity** → a row in `user_profiles` (existing table, unchanged)
- **Provider identity** → one or more rows in `service_provider_profiles` (new table)

The contracting company admin creates a `service_provider_companies` record and invites users to it via the existing Edge Function invite flow. No platform intervention required.

```
auth.users (single email + password)
  ├──► user_profiles                  (employee of one contracting company)
  └──► service_provider_profiles      (member of one or more provider companies)
                                       [one row per provider company]
```

**App login routing:**

| Identities found | Behavior |
|---|---|
| `user_profiles` only | Go directly to **Company Mode** |
| `service_provider_profiles` only | Go directly to **Provider Mode** (enterprise picker if multiple) |
| Both | Show **Mode Switcher** screen |

The last active mode is persisted locally (via `user_parameters` or local storage) so the user does not have to choose on every launch.

---

### 1.2 New Tables

**`service_provider_companies`** — created and managed by the contracting company admin
| Column | Type | Description |
|---|---|
| `company_id` | UUID | FK → the contracting company that manages this |
| `name` | VARCHAR(255) | Provider company name |
| `cnpj` | VARCHAR(14) | Brazilian CNPJ — legal entity (optional) |
| `cpf` | VARCHAR(11) | Brazilian CPF — individual person (optional) |
| `contact_email` | VARCHAR(255) | General contact |
| `contact_phone` | VARCHAR(30) | Optional |
| `is_active` | BOOLEAN | Active status |

> **DB constraint:** `CHECK ((cnpj IS NOT NULL AND cpf IS NULL) OR (cpf IS NOT NULL AND cnpj IS NULL) OR (cnpj IS NULL AND cpf IS NULL))` — at most one document type can be filled.

**`service_provider_profiles`** — individual users of a provider company
| Column | Type | Description |
|---|---|---|
| `auth_user_id` | UUID? | FK → Supabase Auth uid (null until invite accepted) |
| `service_provider_company_id` | UUID | FK → `service_provider_companies.id` (Cascade) |
| `name` | VARCHAR(255) | Display name |
| `email` | VARCHAR(255) | Login email |
| `phone` | VARCHAR(30) | Optional |
| `is_active` | BOOLEAN | Active status |

---

### 1.3 Work Order Assignment — 3 Options

When creating or editing a work order, the responsible party can be:

| Option | Description | Columns set |
|---|---|---|
| **1** | Internal company user | `assigned_to_id` |
| **2** | Provider enterprise (whole company) | `service_provider_company_id` |
| **3** | Provider enterprise + specific technician | `service_provider_company_id` + `provider_profile_id` |

**`work_orders` additions:**
| Column | Type | Description |
|---|---|---|
| `service_provider_company_id` | UUID? | FK → `service_provider_companies.id` (Set Null) |
| `provider_profile_id` | UUID? | FK → `service_provider_profiles.id` (Set Null) |
| `opened_by` | VARCHAR(20) | `'internal'` \| `'provider'` |

---

### 1.4 Provider Mode — Online-Only (V2)

> [IMPORTANT]
> **Provider Mode is online-only in V2.** All data fetching in provider mode goes directly to Supabase. No local Drift caching is used for provider work orders.
>
> **Rationale:** Provider mode spans multiple contracting companies. Scoping the offline-first Drift database to multiple `company_id` values would require a significant architecture change. For V2, providers are expected to have internet connectivity while in the field.

> [NOTE]
> **Future (V3+):** Implement a separate Drift database scope for provider mode, allowing offline access to work orders assigned to the provider's enterprise. This should be designed as an isolated local DB instance, not an extension of the existing employee Drift database.

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

> [NOTE]
> **SLA Scope (Resolved):** SLA policies are **freely configurable per work order** — not tied to priority levels. The company admin creates named policies (e.g. "SLA Urgente = 4h", "SLA Padrão = 48h") and the user selects which policy applies when creating or editing a work order.

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

> [NOTE]
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

## 10. Two-Tier & Scope-Based Permission Architecture

To accommodate attribute-based scoping for work orders (e.g. "Técnico can edit only assigned work orders") while maintaining simplicity for standard features, we implement a two-tier permission model.

### 10.1 Database Schema (JSON Representation)
Both `permission_groups.permissions` and `user_profiles.permissions` JSONB columns will transition from a JSON array of keys (e.g. `["locations.read"]`) to a flat JSON object (e.g. `{"locations.create": true}`). 

Standard resources use boolean keys. Work orders use specific scope/action keys:
```json
{
  "locations.create": true,
  "locations.update": true,
  "locations.delete": false,
  "work_orders.read_scope": "all",
  "work_orders.create": true,
  "work_orders.update_scope": "assigned",
  "work_orders.delete": false,
  "work_orders.change_status": true,
  "work_orders.reassign": false,
  "work_orders.approve_pause": false,
  "work_orders.approve_completion": false
}
```

### 10.2 Server‑Side Database Policies & Helper Functions
1. **Migration SQL**: Modify `public.has_permission(permission_key TEXT)` to support parsing keys out of the flat JSON object (while maintaining array compatibility).
2. **Read Scope Helper**:
   ```sql
   CREATE OR REPLACE FUNCTION public.get_work_orders_read_scope()
   RETURNS TEXT LANGUAGE sql STABLE SECURITY DEFINER AS $$
     SELECT CASE 
       WHEN up.is_admin THEN 'all'
       ELSE COALESCE(pg.permissions ->> 'work_orders.read_scope', 'assigned')
     END
     FROM public.user_profiles up
     LEFT JOIN public.permission_groups pg ON up.permission_group_id = pg.id
     WHERE up.id = auth.uid();
   $$;
   ```
3. **Update Scope Helper**:
   ```sql
   CREATE OR REPLACE FUNCTION public.get_work_orders_update_scope()
   RETURNS TEXT LANGUAGE sql STABLE SECURITY DEFINER AS $$
     SELECT CASE 
       WHEN up.is_admin THEN 'all'
       ELSE COALESCE(pg.permissions ->> 'work_orders.update_scope', 'none')
     END
     FROM public.user_profiles up
     LEFT JOIN public.permission_groups pg ON up.permission_group_id = pg.id
     WHERE up.id = auth.uid();
   $$;
   ```
4. **Row Level Security (RLS)** updates:
   - **`work_orders` SELECT**:
     `company_id = public.get_user_company_id() AND (public.get_work_orders_read_scope() = 'all' OR (public.get_work_orders_read_scope() = 'assigned' AND assigned_to_id = auth.uid()))`
   - **`work_orders` UPDATE**:
     `company_id = public.get_user_company_id() AND (public.get_work_orders_update_scope() = 'all' OR (public.get_work_orders_update_scope() = 'assigned' AND assigned_to_id = auth.uid()) OR (public.get_work_orders_update_scope() = 'own' AND created_by_id = auth.uid()))`

### 10.3 Frontend Integration (Flutter)
1. **Model / Entities**:
   - Introduce `WorkOrdersPermissionEntity` in `lib/features/users/domain/entities/permission.dart` to cleanly model work order scopes and actions.
   - Refactor `PermissionGroupEntity` and `UserProfileEntity` parser methods (`_parsePermissions`) to construct the new nested entities from the flat JSON object.
2. **UsersCubit / Context Helper**:
   - Update `BuildContextExtension.hasPermission()` to support checking permissions with contextual record reference check.
   - Example: `hasPermission(ActionPermission(resource: ResourceType.workOrders, action: PermissionAction.update), record: workOrder)`.
3. **UI / Presentation**:
   - Edit the Group Permissions and User Permissions screens to lock `read` to always-on (not switchable/editable) for standard resources.
   - Display a dropdown/segmented control for `read_scope` (`'all'` \| `'assigned'`) and `update_scope` (`'all'` \| `'assigned'` \| `'own'` \| `'none'`) on `work_orders`.
   - Display switchable toggles for the special work order actions (`change_status`, `reassign`, `approve_pause`, `approve_completion`).

---

## 11. Real-Time Synchronization & Graceful Page Reloads

To improve user experience and avoid manual refreshing, the application will support real-time data push instead of polling timers.

### 11.1 Real-Time Trigger Events
1. **Permissions Change**: When a user's permissions are updated on the server, the app immediately receives the event to update the local cache and security state without requiring a logout/login.
2. **Work Order Modification/Creation**: When a work order is added or modified, the app receives the update from the server to update the local lists.

### 11.2 Graceful Reload Strategy (Avoid Jarring UI Shifts)
To prevent unexpected page jumping or list shifting while the user is scrolling or reading, we will implement the following strategies:
- **Option A (Floating Toast Alert - Recommended)**: When a real-time event is received, show a subtle overlay toast or chip at the bottom/top of the page (e.g., *"Novas ordens de serviço disponíveis. Toque para atualizar"*). The list is refreshed only when the user clicks the action button.
- **Option B (Scroll-Aware Buffering)**: Check if the user is scrolling by listening to the list's `ScrollController`. If the user is actively scrolling, delay the state refresh. The refresh triggers automatically only after the user stops scrolling (idle timeout).
- **Option C (Immediate Reload)**: Refresh the list immediately upon event reception, without scroll checks or toast confirmations.

---

## Resolved Questions

> [NOTE]
> **Q1 — Provider Login:** ✅ **Resolved.** Same login page, auth methods, and flow as internal company users. No separate portal. The app detects which identities exist after login and routes accordingly.
>
> **Q2 — SLA Scope:** ✅ **Resolved.** SLA policies are **freely configurable** per work order. Not tied to priority levels. See §2.1.
>
> **Q3 — Escalation Engine Runtime:** ✅ **Resolved.** Runs server-side as a Supabase Edge Function triggered by `pg_cron`. The engine checks for overdue work orders at regular intervals and sends FCM notifications up the hierarchy (supervisor → manager → admin) automatically, without the app needing to be open.
>
> **Q4 — "Taxa de entrega" (Delivery Rate):** ✅ **Resolved.** A **performance KPI dashboard metric** — percentage of work orders completed within SLA time. Displayed on a reporting/analytics screen.
>
> **Q5 — Provider Work Order Interactions:** ✅ **Resolved.** Service providers can:
> - **Create** work orders
> - **Interact** with assigned work orders (add observations, update progress)
> - **Request pause** — always requires a **selected reason** from a predefined list. The pause request notifies the **contractor company** for approval before the SLA clock is affected.
> - All pauses, regardless of who requests them, go through the approval workflow in §3.
>
> **Q6 — Real-Time Reloading Behavior:** ✅ **Resolved.** Updates are pushed in real time via Supabase Realtime Channels. To prevent jarring UI shifts while scrolling (e.g., when a new work order is created by another user), the application will default to Option A (Toast/Banner notification) or Option B (Scroll-Aware buffering) to let the user control the refresh timing, with a fallback to immediate reload if a simpler approach is preferred.

