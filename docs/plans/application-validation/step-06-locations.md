# Step 06 — Locations

Dependencies: 05. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- LOC-01: ADMIN_A creates a named location with address, reopens and restarts; a second session reads the same ID/fields. Rename and clear optional fields, reload again, cancel deletion, then soft-delete an eligible fixture and prove it is absent from active lists/selectors after fresh login.
- LOC-02: Empty/whitespace/long name, duplicate name with case/accent variation, invalid CEP and failed address lookup. Manual edits survive a late CEP response; invalid input must not leave a partial location.
- LOC-03: Attempt deletion with a linked active asset and with work orders in each relevant status. Assert the table-specific guard; cancelled orders need a separate case because older location guards differ from maintenance-plan guards. Verify dependent rows remain intact after rejection.
- LOC-04: Same-company read-only user and USER_B attempt create/update/delete and direct-ID access; provider lookup read follows its documented contracting-company scope and never grants registry mutation.
- LOC-05: Disconnect, create/edit/delete, restart, reconnect, and inspect the server independently. Current local fallback without a location sync enum is a suspected gap: accepted changes must persist or be visibly pending/rejected, never disappear silently.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** LocationsRemoteDataSource/LocationsRepository, address lookup, Drift filtering, exact-ID soft-delete and foreign-tenant checks; extend existing location integration suite. Inspect `lib/features/locations/data/`, relevant schema/rule files and `test/features/locations/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant LOC persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `locations` data tests passed file by file (5 files, 81 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** Location/CEP validation and use-case error propagation; optional clearing and duplicate-name contract. Inspect `lib/features/locations/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable LOC decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** 2026-09-19: `flutter test --no-pub test/features/locations/domain/use_cases/use_cases_test.dart --reporter expanded` passed 34 tests; targeted analysis passed. Six new contracts preserve write failure details. Input validation, business-rule boundaries, and full feature acceptance remain incomplete.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** Locations/form state, late address responses, duplicate save, realtime upsert/delete and failed-save rollback. Inspect owning state implementations and `test/features/locations/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable LOC cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** 2026-09-19: location Cubit file passed 38 tests; targeted analysis passed. New cases verify failed create/update preserve loaded rows, successful retries reload, and rejected deletion preserves locations/areas. Remaining planned state scenarios are not yet fully covered. See [run records](../../testing/runs/2026-09-19-domain-state-widget.jsonl).

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** Locations list/form/selector journey with full PERSIST and offline reproduction; do not gate delete assertions on autoCleanup. Inspect `lib/features/locations/presentation/` and relevant routed/shared UI. Add focused widget tests and selected proposed `integration_test/` journeys; execute remaining cases with recorded manual steps on the agreed platforms.
- **Acceptance criteria:** Every required LOC scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Format, targeted analysis and affected widget tests; execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** 2026-09-19: location creation-form widget file: 3 passed, 2 failed; targeted analysis passed. VAL-011 and VAL-012 reproduce whitespace-name submission and late address overwrite. Android widget rendering only; full editing/deletion and live journeys remain outstanding. See [run records](../../testing/runs/2026-09-19-domain-state-widget.jsonl).
