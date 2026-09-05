# ServicePro — Application Documentation

> [!NOTE]
> This is the high-level technical overview. For product scope, roadmap, and
> design decisions start at the [CMMS Documentation Index](/docs/cmms/index.md).

## 1. Project Overview

**ServicePro** is a **CMMS (Computerized Maintenance Management System)** for
Brazilian enterprises that manage recurring maintenance across facilities —
hospitals, gyms, factories, hotels, and commercial buildings.

It is a **B2B, single-tenant-per-user** application. A contracting company
registers its locations, areas, and assets, then issues work orders that are
executed either by its own technicians or by external service provider
companies it invites.

The app runs in two distinct modes inside the same codebase:

| Mode | Enum | Audience | Status |
|---|---|---|---|
| **Company (Internal)** | `AppMode.internal` | Employees of the contracting company | Feature-complete |
| **Provider** | `AppMode.provider` | Members of external service provider companies | Feature-complete (dedicated views, RLS, invitations) |

A single Supabase Auth account can hold both identities. Login routing is
handled by `ModeSwitcherCubit`.

> [!IMPORTANT]
> The Flutter package is named `o_jogo_da_obra` for historical reasons. All
> imports use `package:o_jogo_da_obra/...`. "ServicePro" is the product name.

## 2. Technical Stack

Target platforms: Android, iOS, Web, macOS, Windows. Dart SDK `>=3.10.0 <4.0.0`.

| Component | Technology | Purpose |
|---|---|---|
| **Frontend** | Flutter | Cross-platform UI |
| **State Management** | BLoC (Cubit) | Predictable state flow via `BaseCubit` |
| **Authentication** | **Supabase Auth** (email + password) | Same login for both app modes |
| **Remote Database** | Supabase (PostgreSQL) | Relational data, RLS, Edge Functions |
| **Local Database** | Drift (SQLite) | Offline cache, local reads, FIFO queue |
| **File Storage** | Cloudflare R2 (via `minio`) | Attachments, presigned uploads |
| **Push Notifications** | Firebase Cloud Messaging | Device token sync + HTTP v1 Edge Function |
| **Crash Reporting** | Firebase Crashlytics | Stability monitoring |
| **Analytics** | Firebase Analytics | Usage tracking |
| **DI / Routing** | GetIt + Injectable / AutoRoute | Dependency injection and navigation |

## 3. Architectural Rationale

### Clean Architecture
Every feature under `lib/features/<feature>/` is split into `data/`, `domain/`,
and `presentation/`. Cubits depend on use cases, use cases depend on repository
interfaces, and repository implementations coordinate a local and a remote data
source. Conventions are enforced by the agent rules in `.agents/rules/`.

### Why Supabase for both auth and data?
Auth and data live in the same project so that **Row Level Security policies can
key off `auth.uid()` directly**. RLS is the primary enforcement layer for
multi-tenant isolation (`company_id`) and for scope-based work order
permissions (`read_scope` / `update_scope`).

### Why Firebase for crash reporting and messaging?
Crashlytics and FCM are used only for their own concerns. They do not
participate in authentication or data storage.

### Why Drift for the local database?
Drift gives typed SQL, reactive `.watch()` streams, and code-generated DAOs over
SQLite. All local tables live in a single `AppDatabase` class backed by one
`.sqlite` file. Isar was evaluated and abandoned — do not reintroduce it.

## 4. Core Features

**Implemented:**
- **Work orders** — creation, assignment, editing, status lifecycle, search filters, cursor-based pagination
- **Execution tracking** — stopwatch-style play/pause/resume/complete with automatic `actualDuration` calculation and immutable history logging
- **Pause & completion approval workflow** — requests, responsibility classification, supervisor review queue (see [Business Rules](/docs/business_rules.md))
- **SLA policies & Escalation Engine** — configurable per work order, deadline calculation, advance warnings, automated cascading escalation via `pg_cron`
- **Observations** — free-text notes on work orders, flaggable as pending
- **Attachments** — image compression, local-first storage, Cloudflare R2 upload via presigned URLs
- **Change requests** — edits to closed work orders routed to an approval queue
- **Registries** — locations, areas, assets, categories, sectors, pause reasons
- **RBAC** — permission groups plus scope-based work order permissions (`read_scope` / `update_scope`), enforced in both Flutter and RLS
- **Service provider management** — provider companies, profiles, email invitations, and Provider Mode
- **Outbound FIFO Sync Engine** — offline mutation queue, automated retry policies, dead-letter inspection, and error telemetry (see [Sync Engine](/docs/cmms/sync_engine.md))
- **Real-time subscriptions** — live updates via Supabase Realtime channels across lookups and work orders
- **KPI Dashboard & History Consultation** — delivery rate, MTTR, SLA breach metrics, and date-range history filtering
- **Access Logs** — authentication event tracking and consultation

## 5. Roadmap & Pending Work

See the [Internal App Mode Roadmap](/docs/cmms/internal_app_mode_plan.md) for the active priorities:
1. **Checklists & Maintenance Plans Modules** (Milestone 1.2 — standalone templates, checklist executions, and scheduled maintenance plans).
2. **Inventory & Stock Control** (Milestone 1.3 — stock quantities, item usage on work orders).
