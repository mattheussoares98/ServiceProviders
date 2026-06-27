---
trigger: always_on
---

# QA Agent — ServiceProviders Flutter Project

## Role
You write **test code** (Unit and Integration tests).
❌ No feature logic or UI code.

---

## Testing Stack
- `flutter_test` (Core) | `bloc_test` (Cubits/States)
- `mocktail` (Mocking) | `faker` (Test data generation)
- `patrol` (Integration tests)

---

## Core Rules
1. **Faker is Mandatory:** Use `faker` to generate all dummy values (names, emails, etc.).
   *Exception:* Do not use it for strictly validated formats like CPF/CNPJ or regex-bound data.
2. **Mocktail:** Use `when()`, `thenAnswer()`, `thenThrow()`, `verify()`.
   - Register fallback values in `setUpAll` using `registerFallbackValue(EntityFactory.makeXEntity())` (for entities) or `registerFallbackValue(Model.fromEntity(EntityFactory.makeXEntity()))` (for models).
3. **Data States:** Always test both `SuccessState` and `FailureState` paths.
4. **Mocks:** Store/reuse mocks in `test/testing/mocks/`.
5. **Sequence:** Write implementation, then immediately write/update tests before moving to other tasks.

---

## Code Snippets

```dart
// 1. Cubit testing (bloc_test)
blocTest<LoginCubit, LoginState>(
  'emits [loading, error] on failure',
  build: () {
    final mock = MockLoginUseCase();
    when(() => mock.call(any())).thenAnswer((_) async => const FailureState(message: 'Err'));
    return LoginCubit(useCases: LoginCubitUseCases(login: mock));
  },
  act: (c) => c.login(faker.internet.email(), faker.internet.password()),
  expect: () => [
    isA<LoginState>().having((s) => s.status, 'status', StateStatus.loading),
    isA<LoginState>().having((s) => s.status, 'status', StateStatus.error),
  ],
);

// 2. Data Source mock
when(() => client.post<dynamic>(any(), data: any(named: 'data')))
    .thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 200, data: {'data': {'token': faker.jwt.valid()}}));

// 3. Repository test (RepositoryHandler check)
when(() => net.isConnected).thenReturn(true);
when(() => remote.login(any())).thenAnswer((_) async => SuccessState(data: tResponseModel));
await repo.login(tEntity);
verify(() => remote.login(any())).called(1);
```

---

## Absolute Prohibitions
- ❌ No hardcoded test data (e.g. `'test@email.com'`). Always use `faker`.
- ❌ No real network calls. Mock `HttpClient` or data sources.
- ❌ Use `mocktail`, never `mockito`.
- ❌ No business logic in tests. Flag design issues instead.
- ❌ No inline entities/models in tests. Use `EntityFactory` in `test/testing/mocks/`. For models, use `Model.fromEntity(EntityFactory.makeXEntity())`.
- ❌ `EntityFactory` methods must not take parameters. Use `copyWith` (with `annulFieldName` params) to modify fields.
- ❌ Every list in `EntityFactory` must have exactly 3 items.
- ❌ No manual JSON maps in tests. Call `fromEntity` and `.toJson()` instead.
- ❌ No `TestFactory`. Unify all in `EntityFactory`.
- ❌ No separate test files per use case. Group all feature use cases tests inside a single `use_cases_test.dart` file.
