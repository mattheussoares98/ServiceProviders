# Step 14 — Work-order CRUD, assignment, filters, and restoration

Dependencies: 06–13. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- WO-01: Ordinary admin creates an internal order with valid location/area/asset, assignee, category/SLA/checklist and optional money/date fields; persist, reload, update, clear optional fields and independently compare unchanged values.
- WO-02: Create provider order only for an allowed company with the company option enabled; disabled option, forged company, wrong profile/company assignment and inaccessible lookups fail server-side as applicable. No duplicate on double tap or response-loss retry.
- WO-03: Reassign internal technician/provider; old/new assignees refresh simultaneously. Read all/assigned and update all/assigned/own/none, reassign and financial permissions are independently exercised; price/date fields cannot bypass a denied screen through API updates.
- WO-04: Filter by status, priority, type, assignee, date range, search, provider company, delayed and deleted; combine/reset filters. With at least 51 owned fixtures on staging, cross the current 50-row page boundary; no missing/duplicate rows after realtime updates and pagination.
- WO-05: Cancel deletion, delete eligible order, reload active/deleted lists, restore, and verify children/history and permissions. Invalid/deleted/cross-company related IDs and malformed enum/date/amount values leave no partial aggregate.
- WO-06: Concurrent edit/delete/reassign and offline create/update/delete/replay; independent reads distinguish committed, pending and failed operations.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** Work-order aggregate DTO/source/repository, batch children, sync enqueue and existing CRUD/permissions integration suites; fresh-user reads. Inspect `lib/features/work_orders/data/`, relevant schema/rule files and `test/features/work_orders/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant WO persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `work_orders` data tests passed file by file (11 files, 185 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** Filter/scope/assignment/financial validation and nullable-field semantics, UTC/pt-BR date and decimal boundaries. Inspect `lib/features/work_orders/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable WO decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** Partial data validation on 2026-09-19: existing `work_orders` data tests passed file by file (11 files, 185 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** List/detail/create-update state, pagination races, stale requests, duplicate save and rollback. Inspect owning state implementations and `test/features/work_orders/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable WO cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `work_orders` data tests passed file by file (11 files, 185 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** Internal/provider forms, list/detail/deleted filter/restore journeys with PERSIST; follow lifecycle transitions in Step 15. Inspect `lib/features/work_orders/presentation/` and relevant routed/shared UI. Add focused widget tests and selected proposed `integration_test/` journeys; execute remaining cases with recorded manual steps on the agreed platforms.
- **Acceptance criteria:** Every required WO scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Format, targeted analysis and affected widget tests; execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** Partial data validation on 2026-09-19: existing `work_orders` data tests passed file by file (11 files, 185 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.
