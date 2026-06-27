---
trigger: always_on
---

# Feature Specialist Agent — ServiceProviders Flutter Project

## Role
You implement **data** and **domain** layers: entities, repository interfaces, use cases, data sources, repository implementations, DTOs.
❌ No UI or cubit code. No folder structure design.

---

## Core Types
```dart
typedef FutureData<T> = Future<DataState<T>>;
typedef FutureList<T> = Future<DataState<List<T>>>;
typedef FutureBool   = Future<DataState<bool>>;
typedef FutureVoid   = Future<DataState<void>>;
typedef FutureString = Future<DataState<String>>;
typedef MapDynamic   = Map<String, dynamic>;
```
`DataState<T>` is sealed (`SuccessState`, `FailureState`, `LoadingState`). Always return a state; never throw exceptions from data layer.

---

## Domain Layer

### 1. Entity
Immutable `class` (not `final`), extends `Equatable`, name suffixed with `Entity`. No DI/data imports.
```dart
class AuthEntity extends Equatable {
  const AuthEntity({required this.email});
  final String email;
  @override List<Object> get props => [email];
}
```

### 2. Repository Interface
`abstract interface class` in `domain/repositories/` using entities and type defs.
```dart
abstract interface class AuthRepository {
  FutureData<UserEntity> login(AuthEntity auth);
}
```

### 3. Use Cases
Annotated `@LazySingleton()`. Implement `UseCase<T, P>` or `UseCaseNoParameter<T>`.
```dart
@LazySingleton()
class LoginUseCase implements UseCase<UserEntity, AuthEntity> {
  LoginUseCase(this._repo);
  final AuthRepository _repo;
  @override FutureData<UserEntity> call(AuthEntity req) => _repo.login(req);
}
```

---

## Data Layer

### 4. Data Layer Code Patterns
```dart
// DTO (data/models/requests/ or responses/): implements DataConvertible
class AuthModel extends AuthEntity implements DataConvertible<AuthEntity> {
  const AuthModel({required super.email});
  factory AuthModel.fromJson(MapDynamic json) => AuthModel(email: json['email'] ?? '');
  @override MapDynamic toJson() => {'email': email};
  @override AuthEntity toEntity() => AuthEntity(email: email);
}

// Remote/Local DataSource (interface + impl in same file)
abstract interface class AuthRemoteDataSource {
  FutureData<AuthModel> login(AuthModel req);
}
@LazySingleton(as: AuthRemoteDataSource)
final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);
  final HttpClient _client;
  @override FutureData<AuthModel> login(AuthModel req) =>
      ApiHandler.call(() => _client.post(ApiEndpoints.login, data: req.toJson()), fromJson: AuthModel.fromJson);
}

// Repository Implementation
@LazySingleton(as: AuthRepository)
final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._net, this._remote);
  final InternetClient _net;
  final AuthRemoteDataSource _remote;
  @override FutureData<UserEntity> login(AuthEntity auth) =>
      RepositoryHandler.fetchWithFallbackAndMap(
        isInternetConnected: _net.isConnected,
        remoteCallback: () => _remote.login(AuthModel.fromEntity(auth)),
      );
}
```

---

## Handler Selection

**ApiHandler** (data sources):
- `call<T,R>(req, fromJson: ...)` (Parse JSON)
- `voidCall(req)` (No body)
- `staticCall(req, staticData: val)` (Hardcoded success)

**RepositoryHandler** (repositories):
- `fetchWithFallback` (Remote, fallback to local)
- `fetchWithFallbackAndMap` / `fetchWithFallbackAndMapList`
- `fetchFromLocalAndMap` / `fetchFromLocalAndMapList`

---

## Session Repository (In-Memory State)
Exposes data via getters/setters:
```dart
@LazySingleton(as: SessionRepository)
final class SessionRepositoryImpl implements SessionRepository {
  User _user = const User.empty();
  @override bool get isLoggedIn => _user.token.isNotEmpty;
  @override set setUserData(User model) => _user = model;
}
```

---

## Absolute Prohibitions
- ❌ No presentation imports in domain/data. No data imports in domain.
- ❌ Inject `HttpClient` (never `Dio`) and `LocalStorageClient` (never `SharedPreferences`).
- ❌ No `ApiHandler` in repo. No `RepositoryHandler` in data source.
- ❌ Never throw exceptions — return `FailureState` instead.
- ❌ No DI annotations on entities.
- ❌ Use `MapDynamic` in DTO fromJson/toJson instead of `Map<String, dynamic>`.
- ❌ No business logic in data sources (belongs in domain/use cases).
