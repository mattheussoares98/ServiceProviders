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
  - ✅ **Scope-based work order permissions** — the two-tier model is built: `read_scope` / `update_scope` in both the Flutter permission entities and the Supabase RLS helper functions.
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

## Infrastructure & Capability Delivery

### Push Notifications & Device Token Sync ✅ IMPLEMENTED
- `user_device_tokens` table created with RLS and cascade deletion on `auth.users(id)`.
- `NotificationsService` syncs FCM tokens on login, startup, and token refresh, and removes tokens on logout.
- `send-push-notification` Supabase Edge Function dispatches FCM HTTP v1 payloads and cleans up unregistered/stale tokens.
- PostgreSQL database triggers automatically dispatch notifications on work order assignment, pause requests, and observations.

### Provider Mode UI ✅ IMPLEMENTED
- `ProviderHomePage` cubit shell hosting nested router.
- `ProviderWorkOrdersPage` lists assigned work orders across contracting companies.
- `ProviderCompanySelector` for filtering between provider enterprises.
- `WorkOrdersCubit` online-only provider data path (no local cache).
- Restricted provider capabilities via `providerModeAllows` and dedicated RLS branches.
- Provider work order creation, observations, and active-order attachments.

### Outbound Sync & Sync Engine ✅ IMPLEMENTED
- Local FIFO mutation queue backed by Drift [`SyncAuditLogs`](file:///Users/mattheus/Development/Projects/ServiceProviders/lib/core/clients/local/drift/tables/sync_audit_logs_table.dart).
- `SyncEngine` auto-syncs on reconnection and periodic interval.
- Retry limits, dependent cancellation, and error telemetry dispatch to remote `sync_errors`.
- See [`docs/cmms/sync_engine.md`](file:///Users/mattheus/Development/Projects/ServiceProviders/docs/cmms/sync_engine.md).

### Real-time Updates (Supabase Realtime) ✅ IMPLEMENTED
- Realtime publication across work orders and lookup tables.
- `SupabaseRealtimeClient` and `RealtimePayloadMapper`.
- Local Drift cache sync on live remote changes and reactive cubit streams.

### Escalation Engine ✅ IMPLEMENTED
- Configurable escalation parameters in `company_parameters` (advance warning and escalation tiers).
- `public.evaluate_work_order_escalations()` evaluated via `pg_cron` every 5 minutes.
- `CompanyCubit` and `EscalationParametersCard` in `CompanyPage`.
- Overdue filtering in work orders list (`isDelayed`).

### KPI / Reporting Dashboard ✅ IMPLEMENTED
- `CalculateWorkOrderKpisUseCase` computing delivery rate, SLA breach rate, MTTR, and volume counts.
- `DashboardKpisCubit` with responsive `SlaKpiDashboardCard` and period filtering in `DashboardPage`.

### History Consultation by Period ✅ IMPLEMENTED
- `GetWorkOrderHistoryUseCase` with period and keyword filtering.
- `WorkOrderHistoryCubit` and `WorkOrderHistoryPage` integrated with `WorkOrderDetailsPage`.

### Access Logs ✅ IMPLEMENTED
- User login, logout, and session event tracking with IP and device info.
- `AccessLogsPage` with search and date range filters.

### Dependencies Cleanup ✅ RESOLVED
- Removed unused `firebase_auth` and `google_sign_in` from `pubspec.yaml`.

---

## Next Product Priorities

With all V1/V2 infrastructure gaps and provider mode foundations delivered, the next roadmap modules to build are:

1. **Checklists Module (`Milestone 1.2`)**:
   - Checklist templates creation/editing and item configuration.
   - Dynamic checklist execution during work order execution.
2. **Maintenance Plans Module (`Milestone 1.2`)**:
   - Periodic recurring schedules (daily, weekly, monthly, meter-based).
   - Automated generation of work orders from plans via background/cron triggers.
3. **Inventory & Stock Control (`Milestone 1.3`)**:
   - Part/stock registry, minimum stock alerts, and part consumption logging per work order.

