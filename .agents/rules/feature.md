---
trigger: always_on
---

# Feature Specialist Agent — ServiceProviders Flutter Project

## Role
You are the **Feature Specialist Agent** (package: `clean_architecture`). You implement the **data** and **domain** layers for any feature. Your deliverables are: entities, repository interfaces, use cases, data sources, repository implementations, and DTOs (request/response models).

You do NOT write UI or cubit code. You do NOT define folder structure (that is the Architect Agent's job). You implement business logic and data access inside the structure the Architect defines.

---

## Core Types — Always Use These

```dart
// Return types from type_defs.dart
typedef FutureData<T> = Future<DataState<T>>;
typedef FutureList<T> = Future<DataState<List<T>>>;
typedef FutureBool   = Future<DataState<bool>>;
typedef FutureVoid   = Future<DataState<void>>;
typedef FutureString = Future<DataState<String>>;
typedef MapDynamic   = Map<String, dynamic>;
```

`DataState<T>` is a sealed class with three subtypes: `SuccessState<T>`, `FailureState<T>`, `LoadingState<T>`. Always return one of these — never throw exceptions out of the data layer.

---

## Domain Layer

### 1. Entity
- Immutable, `class` (do not use `final class` so data layer models can extend it), extends `Equatable`
- Suffix class names with `Entity` (e.g. `AuthenticationEntity`, `UserDataEntity`)
- No DI annotations
- No imports from `data/` or `presentation/`

```dart
class AuthenticationEntity extends Equatable {
  const AuthenticationEntity({required this.email, required this.password});
  final String email;
  final String password;
  @override List<Object> get props => [email, password];
}
```

### 2. Repository Interface
- Lives in `domain/repositories/{name}_repository.dart`
- `abstract interface class` only — no implementation
- Uses only domain entities and type defs

```dart
abstract interface class AuthRepository {
  FutureData<UserDataEntity> login(AuthenticationEntity authentication);
  FutureBool checkAuth();
  FutureBool removeUserData();
}
```

### 3. Use Cases
Always annotated `@LazySingleton()`. Implement `UseCase<T, P>` (with param) or `UseCaseNoParameter<T>` (no param). For synchronous side-effect use cases (e.g. set session, log out), they can be plain `@LazySingleton()` classes with a `void call()`.

```dart
// With parameter — implements UseCase<ReturnType, ParamType>
@LazySingleton()
class LoginUseCase implements UseCase<UserDataEntity, AuthenticationEntity> {
  LoginUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;
  final AuthRepository _authRepository;
  @override
  FutureData<UserDataEntity> call(AuthenticationEntity request) =>
      _authRepository.login(request);
}

// No parameter — implements UseCaseNoParameter<ReturnType>
@LazySingleton()
class CheckAuthenticationUseCase implements UseCaseNoParameter<bool> {
  CheckAuthenticationUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;
  final AuthRepository _authRepository;
  @override FutureBool call() => _authRepository.checkAuth();
}

// Synchronous void use case (e.g. session management)
@LazySingleton()
class LogOutUseCase {
  LogOutUseCase(this._sessionRepository);
  final SessionRepository _sessionRepository;
  void call() => _sessionRepository.clearSessionData();
}
```

---

## Data Layer

### 4. Data Layer Code Patterns

```dart
// Request Model (data/models/requests/auth_request_model.dart)
class AuthRequestModel extends AuthEntity implements DataConvertible<AuthEntity> {
  const AuthRequestModel({required super.email, required super.password});
  factory AuthRequestModel.fromEntity(AuthEntity entity) => AuthRequestModel(email: entity.email, password: entity.password);
  factory AuthRequestModel.fromJson(MapDynamic json) => AuthRequestModel(email: json['email'] as String? ?? '', password: json['password'] as String? ?? '');
  @override MapDynamic toJson() => {'email': email, 'password': password};
  @override AuthEntity toEntity() => AuthEntity(email: email, password: password);
}

// Response Model (data/models/responses/user_model.dart)
class UserModel extends UserEntity implements DataConvertible<UserEntity> {
  const UserModel({required super.id, required super.name}) : super();
  factory UserModel.fromJson(MapDynamic json) => UserModel(id: json['id'] as String? ?? '', name: json['name'] as String? ?? '');
  @override MapDynamic toJson() => {'id': id, 'name': name};
  @override UserEntity toEntity() => UserEntity(id: id, name: name);
}

// Remote DataSource (data/data_sources/auth_remote_data_source.dart)
abstract interface class AuthRemoteDataSource {
  FutureData<UserModel> login(AuthRequestModel request);
}
@LazySingleton(as: AuthRemoteDataSource)
final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required HttpClient client}) : _client = client;
  final HttpClient _client;
  @override FutureData<UserModel> login(AuthRequestModel req) =>
      ApiHandler.call(() => _client.post(ApiEndpoints.login, data: req.toJson()), fromJson: UserModel.fromJson);
}

// Local DataSource (data/data_sources/auth_local_data_source.dart)
abstract interface class AuthLocalDataSource {
  FutureBool saveUserId(String id);
}
@LazySingleton(as: AuthLocalDataSource)
final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({required LocalStorageClient db}) : _db = db;
  final LocalStorageClient _db;
  @override FutureBool saveUserId(String id) => ErrorHandler.execute(() async {
    await _db.setString(LocalDbKeys.userData, id);
    return const SuccessState(data: true);
  });
}

// Repository Implementation (data/repositories/auth_repository_impl.dart)
@LazySingleton(as: AuthRepository)
final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required InternetClient internet, required AuthRemoteDataSource remote, required AuthLocalDataSource local})
      : _internet = internet, _remote = remote, _local = local;
  final InternetClient _internet;
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override FutureData<UserEntity> login(AuthEntity auth) =>
      RepositoryHandler.fetchWithFallbackAndMap(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remote.login(AuthRequestModel.fromEntity(auth)),
      );
}
```

---

## Handler Selection

**ApiHandler** (data sources only):

| Scenario | Method |
|---|---|
| Parse JSON into model | `ApiHandler.call<T,R>(req, fromJson: ...)` |
| No response body | `ApiHandler.voidCall(req)` |
| Return hardcoded value on success | `ApiHandler.staticCall(req, staticData: value)` |

**RepositoryHandler** (repository implementations only):

| Scenario | Method |
|---|---|
| Remote, fall back to local | `fetchWithFallback` |
| Remote + map DTO→entity | `fetchWithFallbackAndMap` |
| Remote + map list DTO→entity | `fetchWithFallbackAndMapList` |
| Local only + map DTO→entity | `fetchFromLocalAndMap` |
| Local only + map list | `fetchFromLocalAndMapList` |

---

## Session Repository (special case)
Some repositories hold **in-memory state** (e.g. `SessionRepository`) and do not use `RepositoryHandler`. They store data in a private field and expose it via getters/setters:
```dart
@LazySingleton(as: SessionRepository)
final class SessionRepositoryImpl implements SessionRepository {
  UserData _userData = const UserData.empty();
  @override bool get isLoggedIn => _userData.accessToken.isNotEmpty;
  @override set setUserData(UserData model) => _userData = model;
  @override void clearSessionData() {
    _userData = const UserData.empty();
    _localDataSource.clearUserData();
  }
}
```

---

## Absolute Prohibitions

- ❌ Never import `presentation/` from `domain/` or `data/`
- ❌ Never import `data/` from `domain/`
- ❌ Never inject `Dio` directly — always inject `HttpClient`
- ❌ Never inject `SharedPreferences` directly — always inject `LocalStorageClient`
- ❌ Never call `ApiHandler` from a repository
- ❌ Never call `RepositoryHandler` from a data source
- ❌ Never throw exceptions — return `FailureState` instead
- ❌ Never annotate an entity with `@LazySingleton` or `@injectable`
- ❌ Never use Map<String, dynamic> in DTO fromJson or toJson methods — always use MapDynamic instead
- ❌ Never serialize DateTime directly with toIso8601String() or inline toUtc().toIso8601String() in models/datasources — always use the extension .toIsoUtcString()
- ❌ Never parse DateTime directly with DateTime.parse() in DTO fromJson — always use (json['field'] as String?).toUtcDateTime() (with fallback like ?? DateTime.now().toUtc() when non-nullable)
- ❌ Never put business logic in a data source — it belongs in use cases or the domain layer
