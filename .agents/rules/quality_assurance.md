---
trigger: always_on
---

# QA — ServicePro

Writes **tests only** — unit and integration. Never feature logic or UI.

## Stack
`flutter_test` · `bloc_test` (cubit emissions) · `mocktail` (mocking) · `faker` (test data) · `patrol` + `patrol_finders` (integration, on request)

## Mocks & Factories
All mocks and factories live at repo root in **`testing/mocks/`** (not under `test/`):
`factories/` (`asset_factory.dart`, `work_order_factory.dart`, `user_factory.dart`, `checklist_factory.dart`, `system_factory.dart`, `maintenance_plan_factory.dart`, `service_provider_factory.dart`, `factory_helpers.dart`) · `client_mocks.dart` · `data_source_mocks.dart` · `repository_mocks.dart` · `use_case_mocks.dart` · `services.dart` · `external/`

**Factories live in `testing/mocks/factories/` divided by domain.** Rules:
- Factory methods take **no parameters** (`WorkOrderFactory.makeWorkOrderEntity()`, `UserFactory.makeUserProfileEntity()`). Vary fields with the entity's `copyWith`; null a field with `copyWith(annul{Field}: true)`.
- Every list property holds **exactly 3 items**.
- Need a model? Build it from the entity: `CompanyModel.fromEntity(UserFactory.makeCompanyEntity())`.
- Same rule inside `registerFallbackValue()`.
- Shared faker/primitive helpers live in `FactoryHelpers` (`FactoryHelpers.makeEmail()`, `FactoryHelpers.makeDateTime()`, etc.). Id generation is private/internal (`makeId()`) — take an id off a factory entity instead of generating one directly where possible.

## Core Rules
1. **`faker` for all test data** — `faker.internet.email()`, not `'test@email.com'`. Exception: format-validated inputs (CPF/CNPJ, strict regex boundaries) use real valid values.
2. **`mocktail`**: `when()` / `thenAnswer()` / `thenThrow()` / `verify()`. Register `registerFallbackValue()` in `setUpAll` before using `any()` with custom types.
3. **Both outcomes** — every repository and data source test covers `SuccessState` and `FailureState`.
4. **Same-turn testing** — write the implementation, then immediately write/update and run its tests, before touching another component. If a test file already exists and your change could break it, run it.
5. **One file per feature area for use cases** — group all of a feature's use case tests into `use_cases_test.dart` under its `domain/use_cases/` test folder. Never one file per use case.

## Patterns

**Cubit** — `bloc_test`:
```dart
// Data loading: DataStatus.loading -> loaded / loadingError
blocTest<LoginCubit, LoginState>('emits [loading, loaded] on success',
  build: () => LoginCubit(useCases: LoginCubitUseCases(fetchData: mock)),
  act: (c) => c.loadData(),
  expect: () => [
    isA<LoginState>().having((s) => s.status, 'status', DataStatus.loading),
    isA<LoginState>().having((s) => s.status, 'status', DataStatus.loaded),
  ],
);

// Actions: SectionStatus.running -> success / error (then DataStatus.loaded if reloading)
blocTest<LoginCubit, LoginState>('emits [running, success] on action success',
  build: () => LoginCubit(useCases: LoginCubitUseCases(login: mock)),
  act: (c) => c.login(faker.internet.email(), faker.internet.password()),
  expect: () => [
    isA<LoginState>().having((s) => s.sections[LoginSections.login], 'sections', SectionStatus.running),
    isA<LoginState>().having((s) => s.sections[LoginSections.login], 'sections', SectionStatus.success),
  ],
);
```

**Remote data source** — mock `SupabaseDatabaseClient` (or `HttpClient` for the legacy Dio sources).
**Local data source** — mock `AppDatabase`, or use an in-memory Drift database.
**Repository** — mock both data sources plus `InternetClient`, and assert the online and offline branches of `RepositoryHandler` separately:
```dart
test('calls remote source when internet is connected', () async {
  final net = MockInternetClient();
  final remote = MockAuthRemoteDataSource();
  when(() => net.isConnected).thenReturn(true);
  when(() => remote.login(any())).thenAnswer((_) async => SuccessState(data: tModel));
  await AuthRepositoryImpl(internet: net, remote: remote, local: MockAuthLocalDataSource())
      .login(UserFactory.makeAuthentication());
  verify(() => remote.login(any())).called(1);
});
```

## Prohibitions
- ❌ Fixed literals as test data — use `faker`
- ❌ Real network calls — mock the client or data source
- ❌ `mockito` — this project uses `mocktail` only
- ❌ Entities or models constructed inline in a test — always via the domain factory (`WorkOrderFactory`, `UserFactory`, etc.)
- ❌ Hand-written JSON maps — build the model via `fromEntity` and call `.toJson()`
- ❌ Writing business logic to make a test pass — flag the design issue instead
