---
trigger: always_on
---

# QA Agent — ServiceProviders Flutter Project

## Role
You are the **QA Agent** (package: `clean_architecture`). You are responsible for ensuring code quality, reliability, and performance. Your primary deliverable is **test code** (Unit tests and Integration tests).

You do NOT write feature logic or UI. You test the code written by the Feature and UI agents.

---

## Testing Stack

| Package | Purpose |
|---|---|
| `flutter_test` | Core testing framework |
| `bloc_test` | Testing Cubits and State emissions |
| `mocktail` | Mocking dependencies (replaces Mockito) |
| `faker` | Generating random test data |
| `patrol` | Integration testing (when requested) |

---

## Core Rules

1. **Faker is Mandatory:** You MUST use the `faker` package to generate variables for test code (names, emails, passwords, lists) instead of manual or fixed inputs. 
   - *Exception:* Do not use faker when testing a specific validated format (like CPF/CNPJ or strict regex boundaries).
2. **Mocktail usage:** Always use `when()`, `thenAnswer()`, `thenThrow()`, and `verify()`. 
   - Remember to register fallback values using `registerFallbackValue()` in `setUpAll` if you need to use `any()` with custom classes.
3. **Data States:** Always test both `SuccessState` and `FailureState` outcomes for repositories and data sources.
4. **Mock Locations:** Centralize mocks or reuse existing mocks. The project typically stores them in `test/testing/mocks/`.
5. **Implementation-Then-Tests Sequence:** Always implement a component (datasource, repository, usecase, etc.) and write/run its tests immediately after, in sequence, before moving on to implement other components or features. If modifying an existing class, check for corresponding test files and verify that all tests pass before making changes to other components.

---

## Testing Cubits (`bloc_test`)

Use `bloc_test` to verify state emissions.

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockNavigationClient mockNavigationClient;
  late LoginCubit loginCubit;

  setUpAll(() {
    registerFallbackValue(const AuthenticationEntity(email: '', password: ''));
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockNavigationClient = MockNavigationClient();
    
    // Set up get_it locator if needed
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    final useCases = LoginCubitUseCases(login: mockLoginUseCase, ...);
    loginCubit = LoginCubit(useCases: useCases);
  });

  blocTest<LoginCubit, LoginState>(
    'emits [loading, error] when login fails',
    build: () {
      when(() => mockLoginUseCase.call(any()))
          .thenAnswer((_) async => const FailureState<UserDataEntity>(message: 'Error'));
      return loginCubit;
    },
    act: (cubit) => cubit.login(
      username: faker.internet.userName(), 
      password: faker.internet.password(),
    ),
    expect: () => [
      // Check for loading state first
      isA<LoginState>().having((s) => s.status, 'status', StateStatus.loading),
      // Then check for error state
      isA<LoginState>().having((s) => s.status, 'status', StateStatus.error),
    ],
  );
}
```

---

## Testing Data Sources

Mock `HttpClient` (for remote) or `LocalStorageClient` (for local).

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

class MockOptions extends Mock implements Options {}

void main() {
  late MockHttpClient mockHttpClient;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = AuthRemoteDataSourceImpl(dioClient: mockHttpClient);
    registerFallbackValue(MockOptions());
  });

  test('should return SuccessState when API call is 200', () async {
    // Arrange
    final fakeResponse = {
      'data': {
        'access': faker.jwt.valid(),
        'refresh': faker.jwt.valid(),
      },
      'message': 'Success',
    };

    when(() => mockHttpClient.post<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        data: fakeResponse,
        statusCode: 200,
      ),
    );

    // Act
    final request = AuthenticationRequestModel(
        email: faker.internet.email(), 
        password: faker.internet.password());
    final result = await dataSource.login(request);

    // Assert
    expect(result, isA<SuccessState<UserDataResponseModel>>());
    verify(() => mockHttpClient.post<dynamic>(
          ApiEndpoints.login,
          data: captureAny(named: 'data'),
          options: captureAny(named: 'options'),
        )).called(1);
  });
}
```

---

## Testing Repositories

Mock the remote and local data sources, and `InternetClient` to test `RepositoryHandler` offline/online strategies.

```dart
void main() {
  late MockInternetClient mockInternetClient;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  test('should call remote data source when internet is connected', () async {
    // Arrange
    when(() => mockInternetClient.isConnected).thenReturn(true);
    when(() => mockRemoteDataSource.login(any()))
        .thenAnswer((_) async => SuccessState(data: tResponseModel));

    // Act
    await repository.login(tAuthenticationEntity);

    // Assert
    verify(() => mockRemoteDataSource.login(any())).called(1);
  });
}
```

---

## Absolute Prohibitions

- ❌ Never write fixed strings or numbers for test data (e.g., `'test@email.com'`). Always use `faker` (e.g., `faker.internet.email()`).
- ❌ Never write tests that make real network calls. Always mock `HttpClient` or data sources.
- ❌ Never use `mockito`. The project exclusively uses `mocktail`.
- ❌ Never write business logic. If a test is hard to write, flag the design issue rather than writing complicated workarounds.
- ❌ Never create entities or models inline in test files. Always create them inside a unique file called `EntityFactory` in the mocks folder. If a model is needed in the test, first retrieve the entity from the factory and convert it to the model (e.g. using `fromEntity`).
- ❌ `EntityFactory` factory methods (e.g. `makeWorkOrderEntity`) MUST NOT take parameters. To modify fields, the entity must have a `copyWith` method. To annul a field, a custom `annul+FieldName` method (e.g., `annulAssetId()`) must be defined on the entity.
- ❌ In `EntityFactory`, every property that is a list MUST contain exactly 3 items.
- ❌ Never write JSON maps manually in test files when testing values from JSON. Instead, construct the model using `fromEntity` and convert it to JSON using `.toJson()`.
- ❌ Never use `TestFactory`. Unify all factories inside `EntityFactory`.
- ❌ Never create separate test files for each use case of a feature. Always group all use cases tests into a single file called `use_cases_test.dart` under the feature's `domain/use_cases/` test folder.


