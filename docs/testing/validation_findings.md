# Application validation findings

This is the durable backlog for the application-validation work. Do not delete it when a feature plan is retired. Record observed failures separately from suspected causes and test/setup problems. No application or database fixes are authorized by this testing task.

## VAL-001 — Live-test environment parsing changes unquoted passwords

- Status: confirmed test-setup defect; not fixed.
- Date: 2026-09-19. Severity: P1 test blocker (not a reproduced product login defect).
- Evidence: all five configured test accounts authenticated through a direct read-only REST probe, with no super-admin bypass. The Dart readiness suite then returned invalid_credentials for each account.
- Cause evidence: the configured passwords contain unquoted dollar/hash characters. flutter_dotenv 6.0.1 interpolates dollar expressions and removes unquoted hash suffixes. The test harness currently loads those credentials with dotenv.
- Reproduction: `bash tool/run_integration_tests.sh test/integration/tests/readiness_integration_test.dart`.
- Result: 13 cases failed; dependent live cases cannot establish the intended actors. No business-row mutations were performed.
- Future fix: preserve credential bytes through a test-only loader or correctly quoted configuration, then rerun readiness. Never include actual credential values in this document.
- Evidence file: `build/integration_report/20260919T220103Z-39859/report.md`.

## VAL-002 — Supervisor setup does not match application permission names

- Status: confirmed configuration-key mismatch; effective permission denial still needs authenticated Dart verification after VAL-001.
- Date: 2026-09-19. Severity: P1 validation prerequisite.
- Evidence: read-only profile/group inspection returned `work_orders.approve_pause` and `work_orders.approve_completion`, but no `work_orders.manage_pending_requests`, `work_orders.read`, or `work_orders.update` grant for SUPERVISOR_A. The app and plan use the latter permission names.
- Expected: ordinary supervisor can read/update company A orders and manage pending requests; technician cannot approve.
- Future action: reconcile the dedicated test group's intended grants with deployed has_permission and client permissions. Do not change a shared group or silently grant rights to make tests pass.

## VAL-003 — Integration report treats a Flutter daemon event as malformed

- Status: confirmed test-tool defect; not fixed after the user's no-fixes instruction.
- Date: 2026-09-19. Severity: P2 test reporting.
- Evidence: Flutter machine output includes a valid JSON array containing a `test.startedProcess` event. IntegrationRunSummary expects only JSON objects, so the report adds “Malformed runner event.” Actual test failures still propagate correctly.
- Regression: `test/integration_support/integration_run_summary_daemon_test.dart` now reproduces the actual `test.startedProcess` array envelope. Result: 2 passed, 1 failed; targeted analysis passed. Run it alone with `flutter test --no-pub test/integration_support/integration_run_summary_daemon_test.dart --reporter expanded`. The valid-envelope case remains enabled and failing; parser code is unchanged.
- Evidence: `build/file-validation/integration_run_summary_daemon.log` and `docs/testing/runs/2026-09-19-reporter-regression.jsonl`.
- Future fix: accept valid daemon envelopes without ignoring genuine truncated/malformed test evidence.

## VAL-004 — Location and area writes hide local persistence failures

- Status: confirmed application defect; not fixed.
- Date: 2026-09-19. Severity: P2 cache consistency and misleading success.
- Test: `test/features/locations/data/repositories/locations_write_contract_test.dart`, all six “a failed local mirror must not report success” cases.
- Reproduction: `flutter test --no-pub test/features/locations/data/repositories/locations_write_contract_test.dart --reporter expanded` (live opt-in disabled).
- Expected: after server success, a local write/delete returning `FailureState(message: 'disk full', statusCode: 507)` is surfaced to the caller, per `.agents/rules/feature.md`.
- Actual: all six create/update/delete paths discard the local result and return `SuccessState(true)`. The injected failure is deterministic; an actual full disk was not used. The server operation has already succeeded, so any future fix must avoid blind duplicate retries.
- Source: `lib/features/locations/data/repositories/locations_repository_impl.dart`.
- Evidence: `build/file-validation/locations_write_contract.log`; durable counts in `docs/testing/runs/2026-09-19-write-contracts.jsonl`. Tests remain enabled and failing.

## VAL-005 — Offline location and area mutations succeed without replay support

- Status: confirmed application defect; not fixed.
- Date: 2026-09-19. Severity: P1 unsynchronized user work.
- Test: `test/features/locations/data/repositories/locations_write_contract_test.dart`, all six “offline write without replay support must fail” cases.
- Reproduction: same single-file command as VAL-004, with mocked disconnected internet and successful local saves/deletes.
- Expected: reject unsupported offline mutations rather than report synchronized success; `.agents/rules/feature.md` requires a supported replay path for offline writes.
- Actual: each operation returns `SuccessState(true)` without a remote call or enqueue capability. `SyncEntityType` has no locations/areas entry and `LocationsRepositoryImpl` has no sync dependency.
- Impact: offline changes are not delivered to the server. Subsequent server refresh can overwrite edits or hide local-only additions from the returned list; that end-to-end refresh consequence remains to be exercised.
- Evidence: `build/file-validation/locations_write_contract.log`; 6 failing regression cases remain enabled. No production code, live records, or queue types changed.

## VAL-006 — Maintenance-plan mutations discard server error metadata

- Status: confirmed application defect; not fixed.
- Date: 2026-09-19. Severity: P2 diagnostic/error-handling information loss.
- Test: `test/features/maintenance_plans/data/repositories/maintenance_plans_failure_contract_test.dart`, create/update/delete “preserves server denial metadata” cases.
- Reproduction: `flutter test --no-pub test/features/maintenance_plans/data/repositories/maintenance_plans_failure_contract_test.dart --reporter expanded`, live opt-in absent.
- Expected: the caller receives the server's `statusCode: 403`, error code `42501`, and response, consistent with the shared data-state mapping contract.
- Actual: the repository constructs a new failure containing only `message`; statusCode/error/response become null. A failure is still returned; this is not unauthorized access or a false success.
- Evidence: 8 cases pass (generation, detail lookup, empty-response rejection), 3 fail. `build/file-validation/maintenance_plans_failure_contract.log` and `docs/testing/runs/2026-09-19-write-contracts.jsonl`.
- Source: `lib/features/maintenance_plans/data/repositories/maintenance_plans_repository_impl.dart`. No live generation or business mutations occurred.

## VAL-007 — Queue cancellation matches unrelated free-text references

- Status: confirmed application defect; not fixed.
- Date: 2026-09-19. Severity: P1 unintended suppression of offline user work.
- Test: `test/local_integration/sync_recovery_persistence_test.dart`, “canceling an order does not cancel unrelated work mentioning its ID in text”.
- Reproduction: `flutter test --no-pub test/local_integration/sync_recovery_persistence_test.dart --reporter expanded`, disposable on-disk SQLite and no live services.
- Setup: queue one order, its task with a structured `work_order_id` reference, and an unrelated order whose description merely mentions the first order's UUID. Close/reopen, cancel pending work for the first UUID, close/reopen again.
- Expected: first order and its dependent task are canceled; the unrelated order remains pending.
- Actual: pending list is empty. `cancelPendingForEntity` searches all serialized payload text with SQL LIKE and dead-letters the unrelated order too. The data remains in the queue table, but no longer participates in pending replay.
- Additional confirmed paths: `test/local_integration/sync_dead_letter_isolation_test.dart` reproduces the same issue in failed-item lookup and retry (1 passed, 2 failed). Lookup returns unrelated free-text matches; retry changes those unrelated rows from dead_letter to pending and clears their error/attempt history. The third case preserves structured child-reference coverage. Command: `flutter test --no-pub test/local_integration/sync_dead_letter_isolation_test.dart --reporter expanded`; evidence `build/file-validation/sync_dead_letter_isolation.log`. No fix applied.
- Source: `lib/features/sync/data/data_sources/sync_local_data_source.dart`.
- Evidence: `build/file-validation/sync_recovery_persistence.log`; durable run record `docs/testing/runs/2026-09-19-persistence.jsonl` (4 pass, 1 fail). Regression remains enabled.

## VAL-008 — Bulk checklist-answer persistence hides member write failures

- Status: confirmed application defect; not fixed.
- Date: 2026-09-19. Severity: P2 missing cached answers with misleading success.
- Test: `test/local_integration/checklists_persistence_test.dart`, “bulk answer persistence must surface a failed write on a closed database”.
- Reproduction: `flutter test --no-pub test/local_integration/checklists_persistence_test.dart --reporter expanded`, no live services.
- Setup: instantiate a real local source, initialize SQLite, close its connection, then compare one answer write with a one-answer bulk write on that closed source.
- Expected: both operations return `FailureState`; the failed persistence must reach the caller.
- Actual: `saveResponse` returns failure, while `saveResponses` discards that result and returns `SuccessState<void>`. The test deliberately closes a connection to inject a reproducible storage failure; occurrence during real session transitions is not yet verified.
- Evidence: `build/file-validation/checklists_persistence.log`; 3 lifecycle cases pass, 1 fault-injection case fails. Run summary in `docs/testing/runs/2026-09-19-persistence.jsonl`.
- Source: `lib/features/checklists/data/data_sources/checklists_local_data_source.dart`. Regression remains enabled; no fix applied.

## VAL-009 — Clearing settings produces inconsistent notification preferences after restart

- Status: confirmed application defect; not fixed.
- Date: 2026-09-19. Severity: P2 preference consistency.
- Test: `test/local_integration/session_settings_persistence_test.dart`, “clearAll leaves the same notification preference before and after restart”.
- Reproduction: `flutter test --no-pub test/local_integration/session_settings_persistence_test.dart --reporter expanded`, local SQLite only.
- Expected: the notification preference immediately after clearing settings remains the same after reopening the database and initializing a fresh client.
- Actual: `clearAll()` exposes false and removes the settings row; the next initialized client exposes its default true. No push was sent or device authorization changed by this test.
- Evidence: `build/file-validation/session_settings_persistence.log`; source `lib/core/clients/local/local_storage_client.dart`. A future fix must choose one consistent default rather than merely changing this assertion.

## VAL-010 — Failed preference writes still change the in-memory value

- Status: confirmed application defect; not fixed.
- Date: 2026-09-19. Severity: P2 misleading local state after a storage error.
- Test: `test/local_integration/session_settings_persistence_test.dart`, “failed preference persistence does not change the last saved in-memory value”.
- Reproduction: same file command as VAL-009. Save dark theme, close the database, attempt saving light theme on the old client, confirm the write throws, inspect its cached theme.
- Expected: after the failed save, the last successfully saved value remains dark.
- Actual: getter returns light because the cache changes before the awaited database write. This test injects a closed-connection error; it does not claim that a real device ran out of storage.
- Evidence: `build/file-validation/session_settings_persistence.log`; durable result 4 passed/2 failed in `docs/testing/runs/2026-09-19-persistence.jsonl`. Source `lib/core/clients/local/local_storage_client.dart`.

## Recording rules

For each new failure include the exact test file/case, expected and actual results, build/date/environment, sanitized reproduction evidence, severity and status. Distinguish application defects from harness errors, missing fixtures, unsupported devices and unresolved business rules. Do not weaken expectations or alter production code/database state to obtain green results. A passing old test is not evidence that all feature scenarios are covered.

## VAL-011 — Location and area forms accept a whitespace-only required name

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 invalid form submission.
- Regression: `test/features/locations/presentation/pages/create_update_location_page_test.dart`, “rejects whitespace name before saving”.
- Reproduction: open the creation form, type three spaces in its name, and tap Salvar.
- Expected: Campo obrigatório is displayed and saveLocation is not invoked.
- Actual: no required-field error; the form invokes saveLocation. NonEmptyValidator checks isNotEmpty without trimming, while the Cubit trims the submitted name. Server acceptance of the resulting empty string is unverified.
- Evidence: `build/file-validation/locations_widget.log`, durable record `runs/2026-09-19-domain-state-widget.jsonl` (3 passed, 2 failed).

- Additional reproduction: `create_update_area_page_test.dart` also submits a whitespace-only name to saveArea. Final area widget run: 3 passed, 1 failed; failed-save/retry preserves fields and selected location, and back navigation submits nothing. Evidence: `build/file-validation/areas_widget.log`.

## VAL-012 — Late postal-code lookup overwrites a manually edited address

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 user input loss.
- Regression: `test/features/locations/presentation/pages/create_update_location_page_test.dart`, “manual address edit survives a pending postal code lookup”.
- Reproduction: enter a complete CEP, keep its mocked lookup pending, type a corrected street, then complete the lookup with a different street.
- Expected: the manual street remains. Actual: the delayed response replaces it with the postal service street.
- Source: CreateUpdateLocationPage.onCepChanged unconditionally assigns a returned nonempty street. The test uses a deterministic Completer, without a live address service.
- Evidence: `build/file-validation/locations_widget.log`, durable record `runs/2026-09-19-domain-state-widget.jsonl`.

## VAL-013 — Category minimum name length counts surrounding whitespace

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 invalid form submission.
- Regression: `test/features/categories/presentation/pages/category_form_test.dart`, rejects invalid trimmed category name " a ". Executed before the user excluded further widget-test creation.
- Reproduction: enter a one-character name surrounded by spaces and a description, then save.
- Expected: reject the name because its trimmed length is below the form's three-character minimum.
- Actual: saveCategory is called with " a "; MinLengthValidator counts raw characters while CategoriesCubit trims the name. Remote acceptance is unverified.
- Evidence: `build/file-validation/category_form.log`; final file result 5 passed, 1 failed. Whitespace-only and two-character names were rejected in this form. No application fix applied.

## VAL-014 — Logout does not clear selectedCompanyId from local storage

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P1 cross-session tenant leak.
- Regression: `test/features/auth/data/repositories/session_repository_impl_test.dart`, "should clear selectedCompanyId from local storage on logout".
- Reproduction: `flutter test --no-pub test/features/auth/data/repositories/session_repository_impl_test.dart --reporter expanded`.
- Expected: upon calling `SessionRepository.logout()`, `SessionLocalDataSource.saveSelectedCompanyId(null)` is invoked to purge tenant selection.
- Actual: only `saveUserData` and `clearSelectedMode` are called; `selectedCompanyId` remains in local storage. A subsequently logged-in account (e.g. from another company) inherits the prior user's `selectedCompanyId`.
- Source: `lib/features/auth/data/repositories/session_repository_impl.dart`. Test remains enabled and failing; no application fix applied.

## VAL-015 — Inactive user login navigates to home without rejection

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P1 unauthorized access.
- Regression: `test/features/auth/presentation/cubits/login/login_cubit_test.dart`, "login should reject or not navigate to HomeRoute when user is inactive".
- Reproduction: `flutter test --no-pub test/features/auth/presentation/cubits/login/login_cubit_test.dart --reporter expanded`.
- Expected: logging in with an inactive account (`user.isActive == false`) is denied and prevents routing to protected app pages per AUTH-03.
- Actual: `LoginCubit.login` saves user data and replaces route with `HomeRoute()`.
- Source: `lib/features/auth/presentation/cubits/login/login_cubit.dart`. Test remains enabled and failing; no application fix applied.

## VAL-016 — Company-less user without provider profile enters redirect loop

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 redirect loop / denial failure.
- Regression: `test/features/auth/presentation/cubits/login/login_cubit_test.dart`, "login should not navigate to HomeRoute when user has neither internal company nor provider profile".
- Reproduction: `flutter test --no-pub test/features/auth/presentation/cubits/login/login_cubit_test.dart --reporter expanded`.
- Expected: a user lacking both company membership and provider profile must not be routed to `HomeRoute()`; per AUTH-03, company-less users must receive appropriate onboarding/denial instead of a redirect loop.
- Actual: `LoginCubit.login` defaults unassigned users to `AppMode.internal` and routes to `HomeRoute()`, where `CompanyGuard` immediately redirects them back to `LoginRoute()`.
- Source: `lib/features/auth/presentation/cubits/login/login_cubit.dart`. Test remains enabled and failing; no application fix applied.

## VAL-017 — ModeSwitcher loads invalid mode when user lacks matching profile

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 invalid mode resolution.
- Regression: `test/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit_test.dart`, "checkEligibilityAndLoadMode should not select provider mode when user has no provider profile".
- Reproduction: `flutter test --no-pub test/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit_test.dart --reporter expanded`.
- Expected: an internal-only user must not have `selectedMode: AppMode.provider` even if `savedMode` in local storage was set to 'provider' per AUTH-03.
- Actual: `ModeSwitcherCubit.checkEligibilityAndLoadMode` blindly maps `savedMode` to `currentMode` without cross-referencing available profiles.
- Source: `lib/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart`. Test remains enabled and failing; no application fix applied.

## VAL-018 — CompanyCubit.switchCompany mutates user profile to non-existent company ID

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 data integrity / invalid company switch.
- Regression: `test/features/company/presentation/cubits/company/company_cubit_test.dart`, "switchCompany should not switch company or update user profile when target company does not exist in companies list".
- Reproduction: `flutter test --no-pub test/features/company/presentation/cubits/company/company_cubit_test.dart --reporter expanded`.

## VAL-019 — Global wildcard * in permission group JSON omits PermissionAction.read

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 incomplete permission grant on wildcard groups.
- Regression: `test/features/users/data/models/responses/permission_group_model_test.dart`, "should include PermissionAction.read when expanding global wildcard *".
- Reproduction: `flutter test --no-pub test/features/users/data/models/responses/permission_group_model_test.dart --name "should include PermissionAction.read when expanding global wildcard *" --reporter expanded`.
- Expected: expanding global wildcard `{'*': true}` in `PermissionGroupModel.fromJson` grants full permissions (create, read, update, delete) on all resources per USR-01.
- Actual: `PermissionGroupModel._parsePermissions` populates only `{create, update, delete}` for each resource, leaving `read` absent. Users in wildcard groups are evaluated as having `read: false` for all standard resources.
- Source: `lib/features/users/data/models/responses/permission_group_model.dart`. Test remains enabled and failing; no application fix applied.

## VAL-020 — PermissionsCubit.initUser and saveUserPermissions drop user read permission overrides

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 data loss on permission override save.
- Regression: `test/features/users/presentation/cubits/permissions/permissions_cubit_test.dart`, "saveUserPermissions preserves existing user read permission override on standard resources".
- Reproduction: `flutter test --no-pub test/features/users/presentation/cubits/permissions/permissions_cubit_test.dart --name "saveUserPermissions preserves existing user read permission override" --reporter expanded`.
- Expected: when editing user permissions, existing user read overrides on standard resources are preserved per USR-01 ("per-user overrides without dropping unrelated permission keys").
- Actual: `PermissionsCubit.initUser` only iterates over `[create, update, delete]` for standard resources, omitting any pre-existing `read` overrides from `draftUserPermissions`. When `saveUserPermissions` executes, the omitted `read` overrides are completely dropped.
- Source: `lib/features/users/presentation/cubits/permissions/permissions_cubit.dart`. Test remains enabled and failing; no application fix applied.

## VAL-021 — UsersCubit.deletePermissionGroup allows deleting groups assigned to active users

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 referential integrity violation / unhandled in-use deletion.
- Regression: `test/features/users/presentation/cubits/users/users_cubit_test.dart`, "deletePermissionGroup should reject deletion when group is currently assigned to users in state".
- Reproduction: `flutter test --no-pub test/features/users/presentation/cubits/users/users_cubit_test.dart --name "should reject deletion when group is currently assigned" --reporter expanded`.
- Expected: `UsersCubit.deletePermissionGroup` rejects deleting a group that is currently assigned to active users in `state.users` per USR-05 ("Attempt removal of an in-use group, last/required admin, or an assigned user according to the approved rules").
- Actual: `UsersCubit.deletePermissionGroup` calls `_useCases.deletePermissionGroup` unconditionally without checking if any users are assigned to the group.
- Source: `lib/features/users/presentation/cubits/users/users_cubit.dart`. Test remains enabled and failing; no application fix applied.

## VAL-022 — LocationsCubit.saveLocation does not reject whitespace-only location names

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 invalid entity creation / Cubit boundary validation.
- Regression: `test/features/locations/presentation/cubits/locations/locations_cubit_test.dart`, "should reject whitespace-only name without calling createLocation usecase".
- Reproduction: `flutter test --no-pub test/features/locations/presentation/cubits/locations/locations_cubit_test.dart --name "should reject whitespace-only name without calling createLocation" --reporter expanded`.
- Expected: calling `LocationsCubit.saveLocation(id: null, name: '   ')` rejects the empty/whitespace name and emits `SectionStatus.error` without delegating to `CreateLocationUseCase` per LOC-02.
- Actual: `LocationsCubit.saveLocation` trims the name to `""`, constructs an invalid `LocationEntity(name: "")`, and delegates to `CreateLocationUseCase`.
- Source: `lib/features/locations/presentation/cubits/locations/locations_cubit.dart`. Test remains enabled and failing; no application fix applied.

## VAL-023 — LocationsCubit.deleteLocation allows deletion of location with linked areas

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 cascade deletion / orphan areas guard failure.
- Regression: `test/features/locations/presentation/cubits/locations/locations_cubit_test.dart`, "should reject deletion when location has linked areas in state".
- Reproduction: `flutter test --no-pub test/features/locations/presentation/cubits/locations/locations_cubit_test.dart --name "should reject deletion when location has linked areas" --reporter expanded`.
- Expected: `LocationsCubit.deleteLocation` rejects deletion with `SectionStatus.error` when the location has linked areas in local state (`state.areasByLocation[id]`), preserving dependent records per LOC-03.
- Actual: `LocationsCubit.deleteLocation` directly calls `_useCases.deleteLocation` without checking for dependent areas in state.
- Source: `lib/features/locations/presentation/cubits/locations/locations_cubit.dart`. Test remains enabled and failing; no application fix applied.

## VAL-024 — LocationsCubit.saveArea does not reject whitespace-only area names

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 invalid entity creation / Cubit boundary validation.
- Regression: `test/features/locations/presentation/cubits/locations/locations_cubit_test.dart`, "should reject whitespace-only name without calling createArea usecase".
- Reproduction: `flutter test --no-pub test/features/locations/presentation/cubits/locations/locations_cubit_test.dart --name "should reject whitespace-only name without calling createArea" --reporter expanded`.
- Expected: calling `LocationsCubit.saveArea(id: null, locationId: tArea.locationId, name: '   ')` rejects the empty/whitespace name and emits `SectionStatus.error` without delegating to `CreateAreaUseCase` per AREA-03.
- Actual: `LocationsCubit.saveArea` trims the name to `""`, constructs an invalid `AreaEntity(name: "")`, and delegates to `CreateAreaUseCase`.
- Source: `lib/features/locations/presentation/cubits/locations/locations_cubit.dart`. Test remains enabled and failing; no application fix applied.

## VAL-025 — LocationsCubit.saveArea allows creating areas with non-existent parent location

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 orphan record creation / missing parent validation.
- Regression: `test/features/locations/presentation/cubits/locations/locations_cubit_test.dart`, "should reject saving area when parent locationId does not exist in loaded locations".
- Reproduction: `flutter test --no-pub test/features/locations/presentation/cubits/locations/locations_cubit_test.dart --name "should reject saving area when parent locationId does not exist" --reporter expanded`.
- Expected: calling `LocationsCubit.saveArea` with a `locationId` that does not exist in `state.locations` rejects the operation with `SectionStatus.error` without delegating to `CreateAreaUseCase` per AREA-03 ("deleted/missing parent, parent deleted during editing, and forged company/location IDs cannot produce orphan data").
- Actual: `LocationsCubit.saveArea` immediately builds an `AreaEntity` with the unverified `locationId` and delegates to `CreateAreaUseCase`.
- Source: `lib/features/locations/presentation/cubits/locations/locations_cubit.dart`. Test remains enabled and failing; no application fix applied.

## VAL-026 — CategoriesCubit.saveCategory does not reject whitespace-only category names

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 invalid entity creation / Cubit boundary validation.
- Regression: `test/features/categories/presentation/cubits/categories/categories_cubit_test.dart`, "should reject whitespace-only name without calling createCategory usecase".
- Reproduction: `flutter test --no-pub test/features/categories/presentation/cubits/categories/categories_cubit_test.dart --name "should reject whitespace-only name without calling createCategory" --reporter expanded`.
- Expected: calling `CategoriesCubit.saveCategory(id: null, name: '   ')` rejects the empty/whitespace name and emits `SectionStatus.error` without delegating to `CreateCategoryUseCase` per CAT-02.
- Actual: `CategoriesCubit.saveCategory` trims the name to `""`, constructs an invalid `CategoryEntity(name: "")`, and delegates to `CreateCategoryUseCase`.
- Source: `lib/features/categories/presentation/cubits/categories/categories_cubit.dart`. Test remains enabled and failing; no application fix applied.

## VAL-027 — CategoriesCubit.saveCategory does not check for duplicate names within company

- Status: confirmed application defect; not fixed. Date: 2026-09-19. Severity: P2 duplicate record creation / uniqueness guard failure.
- Regression: `test/features/categories/presentation/cubits/categories/categories_cubit_test.dart`, "should reject creating category with duplicate name already existing in state".
- Reproduction: `flutter test --no-pub test/features/categories/presentation/cubits/categories/categories_cubit_test.dart --name "should reject creating category with duplicate name" --reporter expanded`.
- Expected: calling `CategoriesCubit.saveCategory` with a name matching an existing category in `state.categories` (case-insensitive) rejects the operation with `SectionStatus.error` without delegating to `CreateCategoryUseCase` per CAT-02 ("Empty/duplicate/case/long names and repeated submit; no duplicates or misleading success").
- Actual: `CategoriesCubit.saveCategory` performs no duplicate check and delegates to `CreateCategoryUseCase` unconditionally.
- Source: `lib/features/categories/presentation/cubits/categories/categories_cubit.dart`. Test remains enabled and failing; no application fix applied.
