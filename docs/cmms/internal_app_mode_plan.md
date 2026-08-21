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

### Gap 2 — Provider Mode UI ✅ IMPLEMENTED
**Done (2026-08-20):**
- `ProviderHomePage` is now a cubit shell hosting a nested router.
- `ProviderWorkOrdersPage` lists every work order assigned to the provider across all contracting companies.
- `ProviderCompanySelector` narrows to one provider company; shown only when the user belongs to more than one. Default is all companies.
- `WorkOrdersCubit` gained `loadProviderWorkOrders` / `selectProviderCompany` / `applyProviderFilter`; `applyFilter`, `clearFilter` and `loadNextPage` branch on mode.
- Data path is online-only per [V2 §1.4](/docs/cmms/v2_features.md) — `getProviderWorkOrders` deliberately has no Drift fallback and never caches.
- `WorkOrderDetailsPage` is reused unchanged via nested routing.

**RLS** — requires `supabase/migrations/20260820120000_add_provider_access_to_work_orders.sql`, applied 2026-08-20. It adds provider branches to `work_orders` (SELECT/UPDATE/INSERT), `attachments`, `work_order_observations`, and `service_provider_companies`. Without it every provider query returns empty.

**Permissions (2026-08-20)** — provider mode no longer evaluates the internal RBAC of the user's employer. `HasPermissionUseCase` and `UsersCubit.hasPermission` branch on `AppMode` and delegate to `providerModeAllows` (`lib/features/users/domain/entities/permission/provider_mode_permission.dart`), a fixed capability set mirroring the provider RLS branches: read + execute assigned work orders, read/create attachments, read-only lookups, nothing else. Before this, a dual-identity user who was an admin of their own company carried `isAdmin` into provider mode and saw every action on the contracting company's work orders (approve, reassign, delete), while a provider-only user got nothing. The ad-hoc mode checks in `PauseWorkflowCubit._canDirectlyPause` / `_canDirectlyComplete` were removed in favour of that single gate.

**Attachments (2026-08-20)** — `AttachmentsCubit.pickAttachment` took `company_id` from the session. In provider mode `GetActiveCompanyIdUseCase` falls back to the user's own employer (empty for a provider-only user), because `saveSelectedCompanyId` is never called anywhere in `lib/` — the provider company filter lives only in `WorkOrdersCubit.state.activeFilter`. The tenant now comes from the work order being attached to.

**Closed items:**
- ~~**Provider work order creation.**~~ Done (2026-08-21). `CreateProviderWorkOrderPage` is a reduced form — contracting company, location, area, title, description, type, priority, scheduled date. Responsible, SLA policy and status are not offered: they belong to the contracting company, and the order is opened as `open`, assigned to the author's own provider company. Two migrations back it: `20260821140000_widen_provider_access_to_locations_and_areas.sql` and `20260821150000_allow_provider_created_work_orders.sql`, both applied 2026-08-21. The second mirrors the observations authorship split — `created_by_id` is now nullable with `created_by_provider_profile_id` beside it under a single-creator CHECK, because a provider-only user has no `user_profiles` row for the FK to point at. `providerModeAllows` now grants `work_orders.create`.

  **⚠️ Open scope decision — revisit before a customer asks.** A provider now reads the **entire** location and area registry of every contracting company that hired it, including sites it has never worked at. This was accepted deliberately (2026-08-21) because the create form has to browse the registry before any work order exists, and the narrower per-work-order grant cannot serve it. If this becomes a concern, the fix is to restrict the create form's registry to locations where the provider already has work orders, or to add an explicit per-provider site allowlist. `assets` was **not** widened for the same reason — equipment stays on the per-work-order grant, which is why the provider form has no equipment field.

  Not offered yet in the provider form: attachments at creation time, and the estimated duration field.
- ~~**Provider observations.**~~ Done via `supabase/migrations/20260820140000_allow_provider_authored_observations.sql`: `author_id` is nullable, `author_provider_profile_id` was added with a single-author CHECK, and the INSERT/UPDATE policies key the provider branch off `is_own_provider_profile`. `WorkOrderObservationsCubit` resolves the session user's provider profile for the work order's provider company and stamps the tenant from the work order. Applied 2026-08-21.
- ~~**Location and asset labels render blank in provider mode.**~~ Done (2026-08-21) via `supabase/migrations/20260821120000_add_provider_read_access_to_work_order_lookups.sql`: `locations`, `areas` and `assets` gained a provider SELECT branch, granted per work order rather than per contracting company — a provider reads only the rows its own assigned work orders point at. (Locations and areas were widened the same day by `20260821140000` for the create form; `assets` still uses this grant.) This also unblocks `getWorkOrderById`, whose `locations!inner` join made a provider's details reload return "not found". On the Flutter side those cubits cannot fetch by company in provider mode, so `getLocationsByIds` / `getAreasByIds` / `getAssetsByIds` were added down the stack (online-only, no Drift caching, same rationale as `getProviderWorkOrders`) and `ProviderLookupsLoader` feeds them the ids of the loaded work orders. Failures are silent — these are optional labels.

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
Delivered — see Gap 2. What remains is shared with Company Mode: notifications (Gap 1), outbound sync (Gap 3) and real-time (Gap 4).
