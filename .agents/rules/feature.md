---
trigger: always_on
---

# Feature Specialist — ServicePro

Implements **data** + **domain** layers: entities, repository interfaces, use cases, data sources, repository impls, DTOs.
No UI, no cubits (→ `ui.md`). No folder decisions (→ `architect.md`).
Domain lifecycle, SLA, and pause/completion rules: **`docs/business_rules.md`**.

## Core Types
```dart
typedef FutureData<T> = Future<DataState<T>>;
typedef FutureList<T> = Future<DataState<List<T>>>;
typedef FutureBool   = Future<DataState<bool>>;
typedef FutureVoid   = Future<DataState<void>>;
typedef FutureString = Future<DataState<String>>;
typedef MapDynamic   = Map<String, dynamic>;
```
`DataState<T>` is sealed: `SuccessState<T>` | `FailureState<T>` | `LoadingState<T>`. Always return one — never throw out of the data layer.

## Domain

**Entity** — `class` (not `final class`, so models can extend it), extends `Equatable`, `Entity` suffix, no DI, no cross-layer imports. Needs `copyWith`; to null a field, `copyWith` takes `bool? annul{Field}`.
```dart
class AuthenticationEntity extends Equatable {
  const AuthenticationEntity({required this.email, required this.password});
  final String email;
  final String password;
  @override List<Object> get props => [email, password];
}
```

**Repository interface** — `abstract interface class` in `domain/repositories/`, domain types only.

**Use case** — always `@LazySingleton()`. `UseCase<T, P>` with a param, `UseCaseNoParameter<T>` without, or a plain class with `void call()` for synchronous side effects.
```dart
@LazySingleton()
class LoginUseCase implements UseCase<UserDataEntity, AuthenticationEntity> {
  LoginUseCase({required AuthRepository authRepository}) : _authRepository = authRepository;
  final AuthRepository _authRepository;
  @override
  FutureData<UserDataEntity> call(AuthenticationEntity request) => _authRepository.login(request);
}
```

## Data

**Models** extend the entity and implement `DataConvertible<Entity>` with `fromJson` / `toJson` / `toEntity`, plus `fromEntity` on request models. Requests → `data/models/requests/`, responses → `data/models/responses/`.

**Remote data source** — injects `SupabaseDatabaseClient` (or `SupabaseAuthClient` for auth, `StorageClient` for files), wraps every call in `SupabaseHandler`. Table names, columns, and filters live here, never in the client.
```dart
abstract interface class SlaRemoteDataSource {
  FutureList<SlaPolicyModel> getSlaPolicies(String companyId);
}
@LazySingleton(as: SlaRemoteDataSource)
final class SlaRemoteDataSourceImpl implements SlaRemoteDataSource {
  const SlaRemoteDataSourceImpl({required SupabaseDatabaseClient database}) : _database = database;
  final SupabaseDatabaseClient _database;
  @override
  FutureList<SlaPolicyModel> getSlaPolicies(String companyId) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'sla_policies',
      filters: [SupabaseFilter.eq('company_id', companyId), SupabaseFilter.isFilter('deleted_at', null)],
    );
    return response.map(SlaPolicyModel.fromJson).toList();
  });
}
```

**Local data source** — injects `AppDatabase` (Drift), wraps every call in `ErrorHandler.execute`.
```dart
@LazySingleton(as: SlaLocalDataSource)
final class SlaLocalDataSourceImpl implements SlaLocalDataSource {
  const SlaLocalDataSourceImpl({required AppDatabase database}) : _database = database;
  final AppDatabase _database;
  @override
  FutureList<SlaPolicyModel> getSlaPolicies(String companyId) => ErrorHandler.execute(() async {
    final query = _database.select(_database.slaPolicies)
      ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
    return (await query.get()).map(...).toList();
  });
}
```
`LocalStorageClient` (SharedPreferences) is only for small key/value session data — structured records go to Drift.

**Repository impl** — `@LazySingleton(as: Interface)`, injects `InternetClient` + both data sources, delegates to `RepositoryHandler`.
```dart
@LazySingleton(as: AuthRepository)
final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required InternetClient internet, required AuthRemoteDataSource remote, required AuthLocalDataSource local})
      : _internet = internet, _remote = remote, _local = local;
  @override
  FutureData<UserEntity> login(AuthEntity auth) => RepositoryHandler.fetchWithFallbackAndMap(
    isInternetConnected: _internet.isConnected,
    remoteCallback: () => _remote.login(AuthRequestModel.fromEntity(auth)),
  );
}
```

## Handler Selection
| Layer | Handler | Use |
|---|---|---|
| Remote data source (Supabase) | `SupabaseHandler.call` / `.voidCall` | Every Supabase call |
| Local data source (Drift) | `ErrorHandler.execute` | Every Drift call |
| Remote data source (legacy Dio) | `ApiHandler.call` / `.voidCall` / `.staticCall` | Only the 2 remaining `HttpClient` sources |
| Repository | `RepositoryHandler.*` | Never in a data source |

`RepositoryHandler`: `fetchWithFallback` · `fetchWithFallbackAndMap` · `fetchWithFallbackAndMapList` · `fetchFromLocalAndMap` · `fetchFromLocalAndMapList`.

> ⚠️ `fetchWithFallback` is **remote-first**: online → remote, then mirror locally; offline → local only. There is no outbound sync, so offline writes never reach Supabase (see `docs/cmms/architecture.md`).

## In-Memory Repositories
`SessionRepository` and similar hold state in a private field behind getters/setters and use no handler.

## Prohibitions
- ❌ Cross-layer imports (`presentation` from `data`/`domain`; `data` from `domain` is fine, reverse is not)
- ❌ Injecting `Dio`, `SupabaseClient`, or `SharedPreferences` directly — inject `HttpClient`, `SupabaseDatabaseClient`, `LocalStorageClient`
- ❌ `RepositoryHandler` in a data source, or `SupabaseHandler`/`ApiHandler`/`ErrorHandler` in a repository
- ❌ Throwing out of the data layer — return `FailureState`
- ❌ DI annotations on entities
- ❌ Business logic in a data source — it belongs in a use case
- ❌ Raw table/column strings outside a data source
