# Step 10 — SLA policies and pause reasons

Dependencies: 05 and 09. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- SLA-01: Create/update/delete an eligible policy with PERSIST, including target durations and exposed settings. Validate zero/negative/excessive durations and duplicate policy names against approved constraints.
- SLA-02: Assign a policy to an order; change/delete the policy while the order exists. Verify the intended snapshot-versus-live policy behavior and history protection, not an assumed recalculation.
- SLA-03: Inspect and use active pause reasons, including an inactive/deleted reason and a stale selection. If no reason-management screen exists, exercise lookup and authorized API/fixture behavior and mark UI CRUD N/A.
- SLA-04: At the deadline and immediately before/after it, verify overdue classification; no pause, contractor/provider/shared responsibility, resume and multiple pauses use independently calculated expectations (completed in Step 15).
- SLA-05: Provider lookups and ordinary/foreign mutation denials; cancelled/completed order dependencies must use the policy's actual deletion guard.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** SLA sources/models/repository and existing SLA integration suite; pause-reason sources in work_orders; policy/reason grants and guards. Inspect `lib/features/sla_policies/data/`, relevant schema/rule files and `test/features/sla_policies/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant SLA persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `sla_policies` data tests passed file by file (3 files, 30 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** Policy validation and deterministic SLA time/responsibility examples; separate business expectations from implementation arithmetic. Inspect `lib/features/sla_policies/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable SLA decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** Partial data validation on 2026-09-19: existing `sla_policies` data tests passed file by file (3 files, 30 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** SLA policy Cubit and selector loading/errors, stale reason handling and save/delete rollback. Inspect owning state implementations and `test/features/sla_policies/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable SLA cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `sla_policies` data tests passed file by file (3 files, 30 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** SLA policy CRUD and pause-reason selection; time-dependent outcomes integrated with Step 15. Inspect `lib/features/sla_policies/presentation/` and relevant routed/shared UI. Retain selected proposed real-app journeys for the later device-validation stage; execute these with recorded manual steps on the agreed platforms when that stage resumes.
- **Acceptance criteria:** Every required SLA scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** Partial data validation on 2026-09-19: existing `sla_policies` data tests passed file by file (3 files, 30 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.
