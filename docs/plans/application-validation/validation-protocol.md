# Shared validation protocol

## Case identity and independent evidence

Expand each step's scenario families into atomic cases with stable IDs: e.g. `LOC-01-create`, `LOC-01-update`, `LOC-01-delete`, `LOC-02-denied-update`. Record actor/mode, fixture IDs, preconditions, actions, expected state, actual state, and evidence. Avoid one giant test whose first failure hides all later features. Each case creates its own fixtures or uses a declared immutable seed. Capture failure state before teardown.

Expected results come from business rules, approved permission matrices, and schema contracts. Existing implementation is evidence of what to exercise, not proof that its behavior is correct. A conflict between docs, code, and live schema must be resolved as a tracked question; never turn an unexpected permissive result into a passing expectation.

## PERSIST — required for supported mutations

1. **Create:** through the real screen in the UI phase. Save a unique record with known fields; capture its returned ID. Confirm exactly one active row and correct company/relationships through a fresh user-authenticated API read. The data phase separately tests the repository/API contract.
2. **Reload:** navigate away and back, refresh/refetch, fully restart the app or hard-reload the browser, then sign out/in. Verify all saved fields by ID. Repeat from a second authorized session or clean app profile to exclude reliance on the writer's Drift cache. Do not clear the writer's unsynced queue to manufacture a clean result.
3. **Update:** change required and optional fields, deliberately clear a nullable field, save, and repeat independent read/reload. Check fields that were not edited remain unchanged; assert server-generated timestamps with bounded expectations instead of exact client clock equality.
4. **Cancel and reject:** cancel an edit/delete, submit invalid input, and induce permission/network failure. Confirm unchanged persisted state, no unexpected child rows/files, a truthful error, and a working retry. A denied update may affect zero rows without throwing; inspect stored state.
5. **Delete or deactivate:** cancel confirmation first, then accept on a run-owned eligible record. Verify the intended soft-delete/deactivation/revocation, list and selector removal, detail/deep-link behavior, and absence after restart and second-session refresh. Where visible, check actor attribution. Do not infer that disappearance from a filtered list proves a row was deleted.
6. **Dependencies and restoration:** attempt removal with each active dependency and verify the specified rejection. Test completed, cancelled, inactive, and soft-deleted dependency boundaries separately using table-specific rules. Restore only where the app supports it; verify children and references. Append-only records are inspected, not deleted.
7. **Recreate/retry:** repeat the action, double-click, and retry after a lost response. Check for duplicate rows or side effects. Deleted-name reuse and uniqueness follow the deployed constraint; record the intended rule before asserting it.

Every feature applies applicable parts. Settings use save/reload/update/reset; invitations use invite/accept/expire/revoke; logs use append/read/immutability. Mark unsupported lifecycle operations N/A with evidence rather than implementing them for this plan.

## PERM — authorization matrix

For each resource/action test the ordinary allowed role, same-company denied role, unrelated company B, signed-out client, and provider mode where relevant. Cover read list/detail, create, update, soft delete, and each exposed RPC/Edge Function. Try known fixture IDs directly, forged `company_id` and relationship IDs, owner/assignee changes, forbidden fields, and requests made after revocation. Verify denied writes leave parent and child state unchanged. Do not rely only on hidden buttons, HTTP errors, or client-side filters.

Repeat read/update scopes (`all`, `assigned`, and update `own`/`none`), per-user true/false overrides, missing permissions, supported legacy permission representations, and relevant wildcard behavior. `has_permission` alone does not prove company ownership. Check both cached UI permissions and a fresh authenticated request after changing grants. Provider lookup access may be broader than assigned-order access; use the declared contract for each resource.

Realtime denial requires controlled updates to A/B fixtures and an unauthorized subscriber; verify payloads and late events after logout/company switch, not just list contents. File access requires testing the actual serving URL/authorization contract; hiding metadata is insufficient. Explicitly report any public file behavior rather than claiming revocation invalidates a public URL.

## FAULT — realistic interruption and exploratory checks

For each feature cover empty/loading/error states, retry, invalid/duplicate/long input, pt-BR accents, sorting/search/filter reset, pagination where implemented, rapid repeated actions, back navigation with unsaved work, stale/deleted references, and two users editing the same record. Agree on conflict behavior if undocumented; silent loss of an acknowledged change is a defect.

Exercise network loss before send, after server commit but before response, during upload, and during queue replay; app termination and restart; expired session; permissions revoked mid-operation; and realtime reconnect. Use deterministic injected faults in unit/repository tests and bounded staging faults in real-app tests. Provider mode and Maintenance Plans are online-only in current repository paths: expect explicit failure, no silent offline write/fallback. Internal registry offline writes need particular attention because several have local fallbacks but no corresponding sync entity type.

## Test layers and commands

| Layer | Main purpose | Execution after approval |
|---|---|---|
| Data | Independent JSON contracts, repository remote/local behavior, Drift, authenticated API/RLS/RPC, recovery and cleanup | Format changed test files; `flutter analyze <changed-paths>`; `env -u INTEGRATION_TESTS flutter test <affected-data-test-paths>`; gated single live suite below |
| Domain | Permission decisions, recurrence, SLA, transitions, filters, validation boundaries | Format; targeted analysis; `env -u INTEGRATION_TESTS flutter test <affected-domain-test-paths>` |
| Cubits/state | Loading/success/error, rollback, duplicate submits, subscriptions and stale responses | Format; targeted analysis; targeted Cubit `flutter test` with live opt-in unset |
| UI | Widget interactions plus real navigation, reloads, devices, user handoffs | Targeted widget tests; manual recorded journey; selected Patrol app tests once the harness exists |

Paths in angle brackets are templates, not literal runnable commands. Existing feature tests live in `test/features/<feature>/`; shared tests are in `test/core/`, `test/shared_ui/`, and `test/routing/`. Reusable mocks/factories are in `testing/mocks/`; preserve barrel imports. Unit/widget tests use mocked remote clients and in-memory/mock Drift, with no real project network. Group feature use-case tests in `domain/use_cases/use_cases_test.dart` where applicable. Do not run build_runner or edit generated output.

The current live entrypoint is `bash tool/run_integration_tests.sh test/integration/tests/location_integration_test.dart` (substitute a reviewed suite). **Do not run it until Steps 01 and 02 and explicit live-test authorization are satisfied.** Preserve `INTEGRATION_TESTS`, `IntegrationRun.registerGuard()`, and serial `-j 1`. The current script exits zero on test failure; a shell success is not a passing test result. Step 02 must make failure/count/report checks dependable first. Never invoke all suites until their fixture mutations and cleanup have been reviewed.

Patrol and Flutter `integration_test` are declared dependencies, but no root `integration_test/` suite exists. Add only focused real-app journeys during approved UI phases. Discover supported Patrol/Flutter runner flags from installed `--help` and record the exact command, target, flavor, and device after confirming compatibility. Browser journeys may initially be recorded manual checks; do not claim native Patrol coverage proves web behavior.

## Prioritization and cadence

P0/P1: auth, tenant/role isolation, committed persistence, work-order lifecycle, deletion protections, queue loss, duplicate generation, and recovery. P2: secondary filters/settings, usability, and nonblocking states. Run relevant deterministic checks after each change, the feature journey at its UI gate, and the full ordinary regression suite at release. Run live staging suites serially and separately from default tests; use only a small stable UI smoke set for frequent runs and the complete catalogue for release candidates. Do not start CI, scheduled jobs, or deployment as part of writing this plan.

For performance, first record a repeatable baseline, then agree on explicit thresholds for list/detail load, sync drain, upload, and memory on representative devices and data sizes. Use bounded staging volumes at page boundaries, not uncontrolled production load. Include keyboard/focus, screen-reader labels, large text, narrow layouts, pt-BR dates/currency, and light/dark theme in UI checks.

Supabase's [RLS documentation](https://supabase.com/docs/guides/database/postgres/row-level-security) supports checking grants and policies through authenticated clients rather than service-role test actors. The [changelog](https://supabase.com/changelog) was reviewed on 2026-09-19 for relevant planning constraints; recheck version-specific tooling before implementation.
