---
trigger: model_decision
description: Data and domain implementation, including repositories, DTOs, entities, and use cases
---

# Data and domain

Use `architect.md` for boundaries/DI and `docs/business_rules.md` for lifecycle, SLA, pause, and completion behavior. Implement only the authorized layer.

## Contracts

Use aliases from `lib/core/utils/type_defs.dart`: `FutureData<T>`, `FutureList<T>`, `FutureBool`, `FutureVoid`, `FutureString`, `MapDynamic`. One-shot data operations return `DataState<T>` (`SuccessState`, `FailureState`, `LoadingState`); preserve failure metadata instead of swallowing exceptions or reporting success. Realtime operations retain their stream contracts.

- Entities: extensible `class`, `Entity` suffix, `Equatable`, `copyWith`; nullable resets use `bool? annul<Field>`.
- Repository interfaces: `abstract interface class`, domain types in their signatures.
- Use cases: `@LazySingleton()`, `UseCase<T, P>` / `UseCaseNoParameter<T>`; follow existing synchronous contracts for synchronous operations. Business logic belongs here, not in data sources.
- Models: extend entities, implement `DataConvertible<Entity>`, provide `fromJson`, `toJson`, `toEntity`; request models also provide `fromEntity`.

## Data access

| Component | Inject | Handler |
|---|---|---|
| Remote database/auth/files | `SupabaseDatabaseClient`, `SupabaseAuthClient`, or `StorageClient` | `SupabaseHandler.call` / `.voidCall` for Supabase calls; follow the existing storage wrapper for R2 |
| Legacy HTTP source | `HttpClient` | `ApiHandler.call` / `.voidCall` / `.staticCall` |
| Local structured data | `AppDatabase` (Drift) | `ErrorHandler.execute` |
| Repository implementation | `InternetClient` and the required data sources | `RepositoryHandler.*` |

Keep table/column/filter strings and DTO parsing in data sources. Use generic `SupabaseDatabaseClient` CRUD/RPC methods with `SupabaseFilter` / `SupabaseOrder`; do not add table-specific client methods. Feature code injects project wrappers, not raw `Dio`, `SupabaseClient`, or `SharedPreferences`; SDK access belongs inside those wrappers. Repository and data-source handlers must not be interchanged.

`R2StorageClient` intentionally uses a dedicated Dio without the app's auth interceptor for presigned uploads; never send the backend JWT to R2. Credentials stay server-side. `LocalStorageClient` is for small session key/value data; structured records use the single `AppDatabase` through local data sources. Local schema changes require a schema-version bump and upgrade path preserving pending offline work; see `database.md` for remote schema changes.

Inspect `lib/core/data/handlers/repository_handler.dart` for signatures. `fetchWithFallback*` calls remote while online and local only while offline; a remote failure does not trigger local fallback. Missing offline callbacks return `FailureState.noInternet()`. Local mirroring is opt-in via `onRemoteSuccess`, whose failures must propagate. Realtime uses `syncRealtimeStream` for ordered persistence/mapping, including removal of soft-deleted records.

## Tenant and provider boundaries

- Resolve active company with `GetActiveCompanyIdUseCase`; preserve an existing record's `companyId` when editing. Provider creation uses the contracting company, not the user's employer.
- Provider work orders are online-only: no internal Drift fallback, cache writes, or offline enqueueing. Preserve this exception before applying generic offline patterns; reference `work_orders_repository_impl.dart` and its provider tests.
- Scope queries, cache access, realtime subscriptions, and queued payloads to their intended company/user; never broaden access because an ID/filter is missing.

## Offline writes

A local-only write must not silently report a synchronized success:

- Supported internal field work: save locally and call `_syncRepository.enqueue(...)`, preserving entity ID, tenant, user, and replay payload. Handle persistence/enqueue failures. Inspect `SyncEntityType`, `SyncOperationType`, and `ProcessSyncQueueUseCase` before adding an operation; a new enum value alone does not implement replay. Respect layer approval for dependent changes.
- Unsupported admin configuration writes (checklist templates/items): return `FailureState` offline.
- Existing local-only behavior is debt, not a pattern to copy.

In-memory repositories such as `SessionRepository` keep private state behind accessors and require no handler.
