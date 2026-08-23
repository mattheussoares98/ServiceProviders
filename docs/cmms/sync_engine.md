# Sync Engine & Offline Synchronization Architecture

## Overview
The **Sync Engine** (`SyncEngine`) manages the synchronization lifecycle between the local Drift SQLite database and remote backend services (Supabase PostgreSQL, Edge Functions, and Cloudflare R2).

It guarantees:
1. **Zero Data Loss**: Offline mutations are immediately persisted to local SQLite tables and recorded in an outbound `sync_audit_logs` queue.
2. **Strict FIFO Ordering**: Mutations are replayed remotely in the exact sequence they occurred.
3. **Conflict Preservation**: Inbound remote delta syncs never overwrite pending local modifications.
4. **Resilient Failure Handling**: Transient errors trigger automated retries, while unrecoverable/dead-letter failures cascade-cancel dependent operations and log telemetry to `sync_errors`.

```
               ┌───────────────────────────────┐
               │    User Action (Offline)      │
               └──────────────┬────────────────┘
                              │
               ┌──────────────▼────────────────┐
               │  Save to Drift SQLite Table   │
               │  Enqueue in sync_audit_logs   │
               └──────────────┬────────────────┘
                              │ (Network Restored)
               ┌──────────────▼────────────────┐
               │     SyncEngine.processQueue() │
               └──────────────┬────────────────┘
                              │
            ┌─────────────────┴─────────────────┐
            │                                   │
┌───────────▼────────────┐             ┌────────▼──────────────┐
│  Outbound FIFO Flush   │             │ Attachment Uploader   │
│  (Supabase Mutations)  │             │ (Cloudflare R2 + DB)  │
└───────────┬────────────┘             └───────────────────────┘
            │
            │ (When pending == 0)
┌───────────▼────────────┐
│   Inbound Delta Sync   │
│ (syncWorkOrders Delta) │
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│   onSyncCompleted      │
│   (UI Silent Reload)   │
└────────────────────────┘
```

---

## 1. Outbound Sync Queue Lifecycle

### Mutation Enqueueing
When an action is performed (e.g. creating/updating a work order, checklist task, observation, or pause request):
1. The domain entity is mapped and written immediately to the local Drift database.
2. A corresponding `SyncQueueItemEntity` is enqueued into `sync_audit_logs` with `status: 'pending'`, `attempts: 0`, and the JSON mutation payload.

### Processing (`ProcessSyncQueueUseCase`)
When `SyncEngine.processQueue()` executes:
1. Queries `getPendingItems()` ordered by `createdAt ASC` (strict FIFO).
2. For each item:
   - Marks item as `status: 'syncing'` and increments `attempts`.
   - Dispatches the payload to the respective remote repository/data source.
   - **On Success**: Deletes the row from `sync_audit_logs` and continues to the next item.
   - **On Transient Failure (e.g. Network Drop)**: Halts queue draining until connectivity resumes.
   - **On Permanent Failure (e.g. 4xx Conflict / Max Retries Exceeded)**: Marks item as `failed` / `dead_letter`, logs telemetry to the remote `sync_errors` table, and cascade-cancels dependent child requests.

---

## 2. Inbound Sync & Local Overwrite Prevention

A critical guarantee of the sync architecture is that **remote sync must never overwrite unsynchronized local changes**.

### Prevention Rule:
1. `syncWorkOrders(companyId)` (which fetches remote delta changes) is **only executed when `pendingCount == 0`**.
2. If any local mutations are still pending or syncing, remote delta sync is skipped.
3. Once all local queue items have successfully synced to Supabase:
   - `_workOrdersRepository.syncWorkOrders(companyId)` fetches the remote delta changes.
   - `SyncEngine` emits an event on `onSyncCompleted`.
   - `WorkOrdersCubit` listens to `onSyncCompleted` and silently reloads the work orders list in memory.

---

## 3. Error Handling & Cascading Cancellation

### Max Retries & Periodic Retry
1. **Periodic Auto-Retry**: If items remain in a failed state while the device is online, `SyncEngine` re-attempts processing on a periodic timer (e.g. every 60s) or upon network connectivity transitions.
2. **Dead-Letter Threshold**: If an item fails $\ge 3$ times with non-transient errors (or receives a permanent HTTP 4xx like 404 Not Found / 409 Conflict), it is flagged as `dead_letter`.

### Cascading Cancellation
If a parent entity creation fails permanently (e.g. work order `wo-123` creation rejected):
- Subsequent pending operations for that entity (e.g. `update` `wo-123`, `create_observation` for `wo-123`, `create_task` for `wo-123`) cannot succeed.
- The sync engine automatically marks all queued operations referencing `wo-123` as `dead_letter` with the reason `"Parent creation failed"`.
- Sync error telemetry is logged to `sync_errors` for backend diagnostic inspection.

---

## 4. Attachments Synchronization (Cloudflare R2 + Supabase)

Attachments require a two-stage synchronization process handled by `AttachmentsRepository` & `AttachmentsCubit`:

1. **Offline Capture**:
   - File is copied into the local application sandbox.
   - A metadata record is created in Drift SQLite with `uploadStatus: UploadStatus.pending`.
2. **Online Synchronization**:
   - When online, `AttachmentsCubit.refreshAttachments()` scans for pending records.
   - Calls Supabase Edge Function `getPresignedUploadUrl` to generate an authenticated S3/R2 presigned URL.
   - Uploads the raw binary file directly to **Cloudflare R2**.
   - Calls `confirmUpload` to persist the remote attachment record in Supabase PostgreSQL.
   - Updates local Drift SQLite status to `UploadStatus.uploaded`.
3. **Sandbox Pruning**:
   - When the local sandbox exceeds the cache limit (`kSandboxQuotaBytes = 500 MB`), least-recently-used uploaded attachments have their local physical file pruned while preserving the metadata and remote URL.

---

## 5. UI Reactivity

```dart
// WorkOrdersCubit subscribes to SyncEngine on startup:
_syncSubscription = _useCases.syncEngine.onSyncCompleted.listen((_) {
  _refreshWorkOrders();
});
```

- When synchronization completes with zero pending items, `SyncEngine` emits on `onSyncCompleted`.
- `WorkOrdersCubit` automatically refreshes its work orders list without disrupting user scrolling or active filters.
