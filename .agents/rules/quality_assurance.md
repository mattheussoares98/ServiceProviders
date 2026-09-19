---
trigger: model_decision
description: Tests, mocks, factories, and validation of implementation changes
---

# Testing

Use `flutter_test`, `bloc_test`, `mocktail`, and `faker`; use `patrol` / `patrol_finders` for integration tests when requested. Follow the orchestrator's same-turn validation rule. Test work belongs to its implementation layer; a test-only task does not authorize production changes.

## Fixtures

All reusable mocks/factories live at repo root in `testing/mocks/`, not `test/`:

- `factories/`: domain factories and `FactoryHelpers`.
- `data_sources/`, `repositories/`, `use_cases/`: feature mocks; preserve `data_source_mocks.dart`, `repository_mocks.dart`, and `use_case_mocks.dart` as export-only compatibility barrels.
- `client_mocks.dart`, `services.dart`, `external/`: shared/external mocks.

Entity/list factory methods take no parameters (primitive `FactoryHelpers` may). Customize entities with `copyWith`; reset nullable fields with `annul<Field>: true`. Factory list defaults contain three items; override for empty/single/boundary cases. Build models from factory entities using `fromEntity` where supported.

Use faker/`FactoryHelpers` for incidental data; use deterministic fixtures when exact values matter (serialization, ordering, dates, validation boundaries). Prefer IDs from factory entities. Reuse these factories for `registerFallbackValue()` in `setUpAll` before `any()` on custom types.

Avoid inline entity/model construction. Normally derive JSON with `toJson()`; explicit maps are appropriate for independent serialization contracts, malformed input, and missing-field tests. Do not test a serializer solely against its own output.

## Coverage

- Repository/data source behavior: success and failure; repositories also cover online/offline paths, remote-failure propagation, and sync enqueueing when relevant. Provider work-order tests must assert no local cache/fallback/write when that path is touched.
- Unit/widget tests: mock remote project clients; mock `AppDatabase` or use in-memory Drift locally. No real network calls in these tests.
- Cubits: `bloc_test`, asserting `state.section(key).status` (`running` → `success` / `error`) and data/error changes. Read `BaseState`/`BaseCubit` before writing expectations.
- Permission changes: test allowed/denied actions in internal and provider modes, including internal-admin users acting as providers. UI behavior changes need widget coverage for affected interactions and loading/error/empty states where applicable.
- Group each feature's use-case tests in `test/features/<feature>/domain/use_cases/use_cases_test.dart`.
- Run affected existing tests plus focused new tests for changed behavior. Investigate failures; do not weaken assertions to hide defects or fix unrelated production layers without approval.

## Validation commands

For Dart changes, format only changed files, run `flutter analyze <affected paths>` and `flutter test <affected tests>`. Broaden for shared infrastructure changes; use `flutter analyze testing/mocks test` and `flutter test` for broad mock reorganizations. Record actual results, distinguishing pre-existing failures and unavailable tooling. Formatting or compilation alone does not validate behavior. Documentation-only edits use diff, reference, and consistency checks.

`test/integration/` targets the live Supabase project. Preserve `IntegrationRun.registerGuard()` and the `INTEGRATION_TESTS` opt-in; ordinary runs must leave it disabled. Run these suites through `tool/run_integration_tests.sh` only when the user has authorized live integration testing, preserving fixture cleanup/recovery. See `dart_test.yaml` and `test/integration/core/integration_run.dart`.
