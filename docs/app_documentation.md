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
| **Company (Internal)** | `AppMode.internal` | Employees of the contracting company | Feature-complete for V1 |
| **Provider** | `AppMode.provider` | Members of external service provider companies | Backend built; UI pending |

A single Supabase Auth account can hold both identities. Login routing is
handled by `ModeSwitcherCubit` — see [V2 Features §1.1](/docs/cmms/v2_features.md).

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
| **Local Database** | Drift (SQLite) | Offline cache and local reads |
| **File Storage** | Cloudflare R2 (via `minio`) | Attachments, presigned uploads |
| **Push Notifications** | Firebase Cloud Messaging | Receive-side wired; see §5 |
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
multi-tenant isolation (`company_id`) and for the scope-based work order
permissions — see [V2 Features §10](/docs/cmms/v2_features.md). Splitting auth to
a second provider would mean every policy needs a mapping table lookup.

> [!WARNING]
> `firebase_auth` and `google_sign_in` are declared in `pubspec.yaml` but are
> **not imported anywhere** in `lib/`. There is no Google Login in the app today.
> These are leftover dependencies and are candidates for removal.

### Why Firebase for crash reporting and messaging?
Crashlytics and FCM are used only for their own concerns. They do not
participate in authentication or data storage.

### Why Drift for the local database?
Drift gives typed SQL, reactive `.watch()` streams, and code-generated DAOs over
SQLite. All 27 local tables live in a single `AppDatabase` class backed by one
`.sqlite` file. Isar was evaluated and abandoned — do not reintroduce it.

## 4. Core Features

**Implemented (Company Mode):**
- **Work orders** — creation, assignment, editing, status lifecycle, search
  filters, cursor-based pagination
- **Execution tracking** — stopwatch-style play/pause/resume/complete with
  automatic `actualDuration` calculation and immutable history logging
- **Pause & completion approval workflow** — requests, responsibility
  classification, supervisor review queue (see [Business Rules](/docs/business_rules.md))
- **SLA policies** — configurable per work order, deadline calculation, breach
  flagging, net active duration excluding approved pauses
- **Observations** — free-text notes on work orders, flaggable as pending
- **Attachments** — image compression, local-first storage, R2 upload
  (see [Attachments Implementation](/docs/cmms/attachments_implementation.md))
- **Change requests** — edits to closed work orders routed to an approval queue
- **Registries** — locations, areas, assets, categories, sectors, pause reasons
- **RBAC** — permission groups plus scope-based work order permissions
  (`read_scope` / `update_scope`), enforced in both Flutter and RLS
- **Service provider management** — provider companies, profiles, email invitations

**Not yet built:** see the gap list in the
[Internal App Mode Roadmap](/docs/cmms/internal_app_mode_plan.md).

## 5. Known Gaps

These are documented here so they are not mistaken for finished work:

1. **Outbound sync does not exist.** Synchronization is **pull-only** (remote →
   local delta). Records created or edited while offline are written to Drift and
   are **never pushed to Supabase**. The `sync_audit_logs` table is declared in
   Drift but no code reads or writes it. See
   [Architecture](/docs/cmms/architecture.md) for the current vs. intended design.
2. **FCM cannot target users.** The receive side is wired in
   `lib/core/initializations/notifications_initialization.dart`, but no device
   token is ever persisted — there is no token column, table, or migration. No
   server-side dispatch exists. Assignment alerts, pendency alerts, and the
   escalation engine all depend on closing this gap.
3. **Provider Mode has no UI.** `ProviderHomePage` is a placeholder.
4. **No real-time.** Supabase Realtime is not used anywhere; lists refresh
   manually.
5. **No i18n.** ~739 strings are marked with the `.hardcoded` extension awaiting
   extraction. There is no `lib/l10n`. The UI is Portuguese-only.
