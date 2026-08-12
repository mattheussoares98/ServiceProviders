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
   - `registerFallbackValue()` MUST follow the EntityFactory rule: create entities with `EntityFactory`, and when a model is needed, call `Model.fromEntity(EntityFactory.makeXEntity())`. Never instantiate entities or models inline just for fallback registration.
3. **Data States:** Always test both `SuccessState` and `FailureState` outcomes for repositories and data sources.
4. **Mock Locations:** Centralize mocks or reuse existing mocks. The project typically stores them in `test/testing/mocks/`.
5. **Test Verification Sequence:** When creating or changing a datasource, repository, usecase, or any class that can have tests, always check if there is an existing test file. If it exists, verify that all tests pass, but only when the changes made could break them. The sequence of actions must always be: write the implementation of a component, then immediately write/update/run its tests, before moving on to make changes to other files or components.

---

## Testing Cubits (`bloc_test`)

Use `bloc_test` to verify state emissions.

```dart
void main() {
  setUpAll(() {
    registerFallbackValue(EntityFactory.makeAuthentication());
    registerFallbackValue(AuthRequestModel.fromEntity(EntityFactory.makeAuthentication()));
  });
  blocTest<LoginCubit, LoginState>(
    'emits [loading, error] when login fails',
    build: () {
      final mock = MockLoginUseCase();
      when(() => mock.call(any())).thenAnswer((_) async => const FailureState(message: 'Err'));
      return LoginCubit(useCases: LoginCubitUseCases(login: mock));
    },
    act: (cubit) => cubit.login(faker.internet.email(), faker.internet.password()),
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', StateStatus.loading),
      isA<LoginState>().having((s) => s.status, 'status', StateStatus.error),
    ],
  );
}
```

---

## Testing Data Sources

Mock `HttpClient` (for remote) or `LocalStorageClient` (for local).

```dart
void main() {
  test('returns SuccessState when API is 200', () async {
    final client = MockHttpClient();
    when(() => client.post<dynamic>(any(), data: any(named: 'data'), options: any(named: 'options')))
        .thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 200, data: {'data': {'token': faker.jwt.valid()}}));
    
    final result = await AuthRemoteDataSourceImpl(client: client).login(AuthRequestModel(email: faker.internet.email(), password: faker.internet.password()));
    expect(result, isA<SuccessState<UserModel>>());
  });
}
```

---

## Testing Repositories

Mock the remote and local data sources, and `InternetClient` to test `RepositoryHandler` offline/online strategies.

```dart
void main() {
  test('calls remote source when internet is connected', () async {
    final net = MockInternetClient();
    final remote = MockAuthRemoteDataSource();
    when(() => net.isConnected).thenReturn(true);
    when(() => remote.login(any())).thenAnswer((_) async => SuccessState(data: tModel));

    await AuthRepositoryImpl(internet: net, remote: remote, local: MockAuthLocalDataSource()).login(tAuthenticationEntity);
    verify(() => remote.login(any())).called(1);
  });
}
```

---

## Absolute Prohibitions

- ❌ Never write fixed strings or numbers for test data (e.g., `'test@email.com'`). Always use `faker` (e.g., `faker.internet.email()`).
- ❌ Never write tests that make real network calls. Always mock `HttpClient` or data sources.
- ❌ Never use `mockito`. The project exclusively uses `mocktail`.
- ❌ Never write business logic. If a test is hard to write, flag the design issue rather than writing complicated workarounds.
- ❌ Never create entities or models inline in test files. Always create them inside a unique file called `EntityFactory` in the mocks folder. If a model is needed in the test, first retrieve the entity from the factory and convert it to the model (e.g. `CompanyModel.fromEntity(EntityFactory.makeCompanyEntity())`). This applies to every test setup, including `registerFallbackValue()`.
- ❌ `EntityFactory` factory methods (e.g. `makeWorkOrderEntity`) MUST NOT take parameters. To modify fields, the entity must have a `copyWith` method. To annul a field, the entity's `copyWith` method must accept a `bool? annul+FieldName` parameter (e.g. `copyWith(bool? annulAssetId)`).
- ❌ In `EntityFactory`, every property that is a list MUST contain exactly 3 items.
- ❌ Never write JSON maps manually in test files when testing values from JSON. Instead, construct the model using `fromEntity` and convert it to JSON using `.toJson()`.
- ❌ Never use `TestFactory`. Unify all factories inside `EntityFactory`.
- ❌ Never create separate test files for each use case of a feature. Always group all use cases tests into a single file called `use_cases_test.dart` under the feature's `domain/use_cases/` test folder.

