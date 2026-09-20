# Step 13 — Checklist templates, items, and answers

Dependencies: 08 and 11; answer cases require a minimal work-order fixture. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- CHK-01: Create a template, add/reorder/edit/remove items, update template fields and reload. Delete eligible items/template; linked-order/template deletion and later edits must follow the approved historical-answer contract.
- CHK-02: Cover all seven item types: boolean, text, number, photo, documentation, selection and multi-selection. Test required/optional, false/zero/empty distinction, numeric boundaries, missing/duplicate options, changed options and invalid stored answers.
- CHK-03: Attach to an order; technician answers and updates responses, restarts, and supervisor/provider authorized sessions see the same values. Required unanswered items block completion when configured; failed save cannot display an unsaved answer as committed.
- CHK-04: Copy/reuse a template across two orders; one order's answers never overwrite the other's. Update/delete a template item after answers exist and verify history behavior. Concurrent answer updates do not silently duplicate records.
- CHK-05: Providers may answer within their execution scope but cannot author templates. Foreign order/item/answer IDs, offline replay, duplicate submit and interrupted photo/document answers need direct persistence/isolation checks.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** Checklist templates/items/answers sources and answer uniqueness/relationships; new live suite proposed, reuse existing data tests. Inspect `lib/features/checklists/data/`, relevant schema/rule files and `test/features/checklists/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant CHK persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `checklists` data tests passed file by file (4 files, 62 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** Item-type/required-answer validation and response mapping independent of DTO round trips. Inspect `lib/features/checklists/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable CHK decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** Partial data validation on 2026-09-19: existing `checklists` data tests passed file by file (4 files, 62 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** Template/item editors and work-order answer state, unsaved values, failure rollback and realtime updates. Inspect owning state implementations and `test/features/checklists/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable CHK cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `checklists` data tests passed file by file (4 files, 62 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** All seven input widgets, template CRUD and answer reload; file cases continue in Step 17, completion gate in Step 15. Inspect `lib/features/checklists/presentation/` and relevant routed/shared UI. Retain selected proposed real-app journeys for the later device-validation stage; execute these with recorded manual steps on the agreed platforms when that stage resumes.
- **Acceptance criteria:** Every required CHK scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** Partial data validation on 2026-09-19: existing `checklists` data tests passed file by file (4 files, 62 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.
