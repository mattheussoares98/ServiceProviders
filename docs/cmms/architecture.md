# Architecture — Offline-First Design

## Data Flow

```
┌───────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                           │
│  Pages/Widgets → Cubit (BaseCubit) → Use Cases               │
└──────────────────────────┬────────────────────────────────────┘
                           │
┌──────────────────────────▼────────────────────────────────────┐
│  DOMAIN LAYER                                                 │
│  Repository Interface (abstract)                              │
└──────────┬───────────────────────────────────┬────────────────┘
           │                                   │
┌──────────▼──────────┐            ┌───────────▼───────────────┐
│  LOCAL DATA SOURCE  │            │  REMOTE DATA SOURCE       │
│  (Drift / SQLite)   │            │  (Supabase PostgreSQL)    │
│  ═══════════════    │            │  ═══════════════════      │
│  • Source of truth  │            │  • Remote backup          │
│  • Works offline    │            │  • Multi-device sync (V2) │
│  • Reactive .watch()│            │  • Files → Cloudflare R2  │
└─────────────────────┘            └───────────────────────────┘
```

## Offline-First Principle: Local DB is the Source of Truth

1. **All writes go to Drift first** — the UI never waits for a network call to perform CRUD.
2. **Reactive queries** — UI uses Drift's `.watch()` streams so the interface updates instantly when local data changes.
3. **Bidirectional Sync Engine in V1** — A background synchronizer is implemented in V1 to sync local database events (inserts, updates, soft deletes) to Supabase and pull remote changes using a First-In, First-Out (FIFO) queue logic.

## What Can Be Done Offline?

Not everything should be editable offline. Allowing unrestricted offline edits creates difficult conflict resolution problems. Here is the strategy:

| Operation | Offline? | Rule |
|---|---|---|
| **Create** a work order | ✅ Yes | UUID generated locally. Syncs when online (V2). |
| **Edit** an open work order **you created** | ✅ Yes | Safe because you own it. |
| **Edit** an open work order **someone else created** | ✅ Yes | Allowed — if conflicts occur on closed orders, they become change requests. |

## Handling Closed Work Orders (FIFO Sync & Change Requests)

To maintain historical integrity and prevent tampering with finalized data, edits to closed work orders follow a strict approval workflow:
1. **Direct Updates Locked**: Once a `WorkOrder` status is set to `completed` or `cancelled`, it cannot be directly edited/updated in the database by any normal user.
2. **Database Trigger Redirection**: Incoming sync writes or updates on a closed work order (including adding tasks or attachments) are intercepted by a database trigger in Supabase (or locally handled in Drift). The trigger automatically routes the edit details into the `work_order_change_requests` table and cancels the original update, allowing the FIFO sync queue to complete successfully without errors.
3. **Cross-User Edits Allowed**: Because all edits on closed work orders are redirected to change requests, the app can safely allow users to edit/close work orders created by other users. If a conflict occurs (e.g., A closes it while B is offline editing it), B's offline edits will automatically convert into change requests when synced.
4. **Offline Alert Dialogs**: Technicians working offline can be notified of unsynced items. If the device remains offline for a set time (e.g., `maxOfflineDurationHours`) or the local queue exceeds a specific count (e.g., `maxOfflinePendingRequests`), the app will display a warning dialog. These alert thresholds are configurable per company via the `company_parameters` table.
5. **Admin Approval Queue**: Gestores and Admins see a queue of pending requests:
   - **Approve**: Reopens the work order temporarily, merges the requested changes (adding the items/files), and closes the order again.
   - **Reject**: Rejects the request with an optional reason, leaving the closed order intact.
6. **No Data Loss**: Even though edits are blocked directly, the technician's input is saved in the database as a request, preventing work from being lost.

## Work Order Stopwatch Workflow (Play / Pause / Stop)

To ensure accurate labor time tracking and prevent manual input fabrication, the application implements a stopwatch-style tracking workflow:

1. **Start Work (Play)**: 
   - When a technician begins working on an active work order, they tap **"Start"**.
   - The app records the timestamp `startedAt = DateTime.now()` and changes the status to `in_progress`.
   - A new record is added to the `work_order_history` log: `"Trabalho iniciado"`.
2. **Pause Work (Pause)**: 
   - If the technician takes a break or waits for parts, they can tap **"Pause"**.
   - The app records the pause interval.
   - A record is added to the history: `"Trabalho pausado"`.
3. **Stop/Complete Work (Stop)**: 
   - Once the task is finished, the technician taps **"Complete"**.
   - The app records `completedAt = DateTime.now()`.
   - The system automatically calculates `actualDuration` as `(completedAt - startedAt) - totalPausedDuration`, converting it into minutes.
   - The status is changed to `completed`, and a final record is added to the history: `"Trabalho concluído"`.
4. **Historical Logging**: 
   - All state transitions (Play, Pause, Resume, Stop) are logged as immutable audit events in the `work_order_history` table to guarantee full accountability and auditability.


## File Management Strategy

Here is how photos/PDFs are handled step by step:

1. **User picks a file** — via camera, gallery, or file picker
2. **Image compression** — if it's an image, `image_compress_plus` compresses it (max 1920px, quality 75-80, WebP format). This reduces a 5MB photo to ~300-500KB while maintaining good visual quality
3. **File copied to app sandbox** — using `path_provider`, the file is moved into the app's secure local directory
4. **Attachment record saved to Drift** — with `localPath`, `uploadStatus: pending`
5. **App works fully offline at this point** — the file is visible in the UI from the local path
6. **(V2) When online** — the file is uploaded to Cloudflare R2 via a presigned URL, and the `remoteUrl` + `uploadStatus: uploaded` are saved

> [!NOTE]
> PDF and document files are NOT compressed — only images. The `isCompressed` flag on the Attachment entity tracks whether compression was applied.

## User Invitation Flow

Supabase supports inviting users by email via the Admin API. Here is the planned flow:

1. **Admin clicks "Convidar Usuário"** in the app
2. **App calls a Supabase Edge Function** with the invitee's email and the company's `company_id`
3. **Edge Function calls `auth.admin.inviteUserByEmail()`** — this sends a magic link email to the invitee. The `company_id` is attached as `user_metadata`
4. **Invitee receives email** → clicks the link → is redirected to the app
5. **If the user is NEW**: They land on a "Set Password" screen. After setting their password, a `user_profiles` row is automatically created (via a Supabase trigger) linking them to the company
6. **If the user ALREADY EXISTS**: The invite link still works, but the trigger checks if they already have a profile and links them to the new company

> [!IMPORTANT]
> The service role key (required for `inviteUserByEmail`) is **never** exposed in the Flutter app. It lives only in the Supabase Edge Function.

## Core Infrastructure

### Drift Database Setup (Single Local Database)
```
lib/core/clients/local/drift/
├── app_database.dart              # Main database class, all tables, migrations
├── app_database.g.dart            # Generated by drift_dev
├── tables/                        # One file per table definition
│   ├── companies_table.dart
│   ├── locations_table.dart
│   ├── areas_table.dart
│   ├── assets_table.dart
│   ├── work_orders_table.dart
│   ├── tasks_table.dart
│   ├── maintenance_plans_table.dart
│   ├── checklist_templates_table.dart
│   ├── checklist_items_table.dart
│   ├── attachments_table.dart
│   ├── categories_table.dart
│   ├── permission_groups_table.dart
│   ├── user_profiles_table.dart
│   ├── work_order_change_requests_table.dart
│   ├── company_parameters_table.dart
│   ├── sync_audit_logs_table.dart
│   └── work_order_history_table.dart
└── daos/
    ├── work_order_dao.dart
    ├── asset_dao.dart
    ├── maintenance_plan_dao.dart
    ├── checklist_dao.dart
    ├── work_order_change_request_dao.dart
    └── work_order_history_dao.dart
```

> [!NOTE]
> All 17 tables live inside a **single `AppDatabase` class** → a **single `.sqlite` file** on disk. Drift tables will declare local `@Index` annotations mirroring PostgreSQL indexes to prevent frame drops on mobile CPUs when searching and filtering.

### Supabase Database Client
```
lib/core/clients/remote/supabase/
├── supabase_auth_client.dart          # Auth-only wrapper around Supabase Auth
├── supabase_database_client.dart      # Generic structured CRUD/RPC wrapper
└── supabase_module.dart               # Injectable module for Supabase SDK clients
```

> [!IMPORTANT]
> Remote feature data sources must use the generic `SupabaseDatabaseClient` methods (`selectOne`, `selectList`, `insert`, `update`, `upsert`, `delete`, `rpc`) with structured `SupabaseFilter` and `SupabaseOrder` values. Do **not** add one method per table/action to `SupabaseDatabaseClient` (for example, avoid `getUserProfile`, `getCompany`, `getAssets`). Table names, columns, filters, and DTO parsing belong inside each feature data source.

### File Storage Client
```
lib/core/clients/remote/storage/
├── storage_client.dart                # Abstract interface for file operations
└── r2_storage_client.dart             # Cloudflare R2 implementation using minio
```
