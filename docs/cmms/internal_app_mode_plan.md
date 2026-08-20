# Roadmap: Complete Company Mode (`AppMode.internal`) First

## Overview
This document tracks the strategic roadmap for completing **Company Mode**
(`AppMode.internal`) in full before continuing work on **Provider Mode**
(`AppMode.provider`). Both modes are treated as distinct applications residing
within the same codebase.

All features, workflows, permissions, UI components, and automated tests for
Company Mode are completed and validated first.

---

## Phase 1: Company Mode

### Milestone 1.1: Work Order Execution (Core MVP) — ✅ IMPLEMENTED
- **Work Order Details & Execution**:
  - ✅ Execution timer (`FormattedDurationTimerText`) with real-time ticking, adaptive unit formatting, and `RepaintBoundary` performance isolation.
  - ✅ Photo and document attachments per Work Order (`lib/features/attachments`).
  - ✅ Digital sign-off upon completion.
  - ✅ Work orders list with search filters and cursor-based pagination.
- **Checklist Responses** — ⏸️ ON HOLD (resume when explicitly requested).

### Milestone 1.2: Checklists & Maintenance Plans Modules — ⏸️ ON HOLD
> Template management, standalone checklists, and automated maintenance plans are deferred. Drift tables and stub features exist (`lib/features/checklists`, `lib/features/maintenance_plans`) but are not wired into the product.

### Milestone 1.3: Inventory & Stock Control — ⏸️ ON HOLD
> Inventory stock management and product usage tracking are deferred for future releases.

### Milestone 1.4: Sectors, Categories & RBAC Administration — ✅ IMPLEMENTED
- **Registries**: ✅ Sectors (`lib/features/sectors`), Categories (`lib/features/categories`), Locations, Areas, Assets, Pause Reasons.
- **Role-Based Access Control (RBAC)**:
  - ✅ `ResourceType`, permission groups, and per-user permission overrides.
  - ✅ **Scope-based work order permissions** — the two-tier model from [V2 Features §10](/docs/cmms/v2_features.md) is built: `read_scope` / `update_scope` in both the Flutter permission entities and the Supabase RLS helper functions.
  - ✅ Dual App Mode (`AppMode.internal` & `AppMode.provider`), `ModeSwitcherCubit`, and mode-aware login routing.
  - ✅ Service Provider backend — migrations, remote data source, repository, cubit, `CreateServiceProviderCompanyPage`, and the invitation flow.

### Milestone 1.5: SLA & Approval Workflows — ✅ IMPLEMENTED
- ✅ `sla_policies` feature with per-work-order policy selection.
- ✅ `sla_deadline_at`, `sla_breached`, and `net_active_duration` calculated and persisted.
- ✅ Pause request workflow with responsibility classification and supervisor review.
- ✅ Completion approval workflow (`pending_approval` → approve/reject).
- ✅ Work order observations, flaggable as pending.
- ✅ Change request queue for edits to closed work orders.
- See [Business Rules](/docs/business_rules.md) for the authoritative rule matrix.

---

## Open Gaps — Ranked

These block features already promised in [V1 scope](/docs/cmms/index.md) or [V2 Features](/docs/cmms/v2_features.md). Ordered by leverage.

### Gap 1 — FCM cannot target a user 🔴
`lib/core/initializations/notifications_initialization.dart` requests permission, registers background/foreground handlers, and shows local notifications. But **no device token is ever read or stored**: there is no token column, no table, and no migration for one. No server-side dispatch exists.

**Blocks:** work order assignment notifications (V1 scope), pendency notifications ([V2 §4.2](/docs/cmms/v2_features.md)), and the entire escalation engine ([V2 §5](/docs/cmms/v2_features.md)).
**Work:** device token table + migration, token registration/refresh on login, an Edge Function to dispatch by user.

### Gap 2 — Provider Mode has no UI 🔴
`ProviderHomePage` renders a placeholder `Text('Provider Home')`. The repository, use cases, `ServiceProvidersCubit`, and `ModeSwitcherCubit` routing are all built and reachable.

**Work:** provider work order list, provider-scoped detail/execution view, enterprise picker for providers belonging to multiple contracting companies. Per [V2 §1.4](/docs/cmms/v2_features.md), Provider Mode is **online-only** — no Drift caching.

### Gap 3 — Outbound sync does not exist 🔴
Sync is pull-only (`syncWorkOrders`, work orders only). Offline writes land in Drift and are never pushed. `sync_audit_logs` is declared in the Drift schema but unused.

**Impact:** the offline-first promise in [Architecture](/docs/cmms/architecture.md) is not met. Data created in the field without connectivity is silently lost to the server.

### Gap 4 — No real-time ([V2 §11](/docs/cmms/v2_features.md)) 🟡
Supabase Realtime is not referenced anywhere in `lib/`. Lists refresh only on manual pull or cubit init. Design is already resolved (Option A toast / Option B scroll-aware buffering).

### Gap 5 — Escalation engine ([V2 §5](/docs/cmms/v2_features.md)) 🟡
Not started — no `escalation_policies` table, no Edge Function, no `pg_cron` job. Depends on Gap 1.

### Gap 6 — KPI / reporting dashboard (Q4 in [V2 Resolved Questions](/docs/cmms/v2_features.md)) 🟡
`DashboardPage` shows counts, active items, and recent work orders. "Taxa de entrega" (% completed within SLA), breach rate, and mean time-to-resolve are not reported anywhere — though the underlying SLA data is already captured.

### Gap 7 — History consultation by period ([V2 §8](/docs/cmms/v2_features.md)) 🟢
Cheapest item. `GetWorkOrderHistoryUseCase` exists; needs a date-range filter and UI. No schema change required.

### Gap 8 — Access logs ([V2 §7](/docs/cmms/v2_features.md)) 🟢
Not started. Low complexity, compliance value.

### Gap 9 — Localization 🟢
~739 `.hardcoded` call sites, no `lib/l10n`. Fine while the product is Brazil-only; the cost grows with every new screen.

### Gap 10 — Unused dependencies 🟢
`firebase_auth` and `google_sign_in` are in `pubspec.yaml` but imported nowhere. Authentication is Supabase email + password only.

---

## Phase 2: Provider Mode (`AppMode.provider`) UI
Provider Mode backend and cubit layers are already built. Blocked on Gap 2 above.
