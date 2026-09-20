# Step 15 — Work-order pause, completion, and SLA lifecycle

Dependencies: 10 and 14; required evidence uses 13/17 as applicable. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- LIFE-01: TECH_A starts open order → requests pause. Expect order onHold and pending pause. SUPERVISOR_A reviews responsibility while still paused; status stays onHold. Repeat resume-before-review: order inProgress, resumed_at set, pause still pending; later review must not pause it again.
- LIFE-02: Authorized internal supervisor pauses directly: order onHold, pause approved and no pending-review item. A provider with internal admin rights still takes the pending request branch.
- LIFE-03: Technician/provider requests completion → pendingConclusionApproval with pending request. Manual status dropdown/API bypass cannot evade the approval requirement. Approve → completed with completedAt; separate reject case → inProgress. Retry/review races must not apply two conflicting decisions.
- LIFE-04: Supervisor with managePendingRequests completes directly → completed and approved request. Missing required checklist/evidence/reason/sector under enabled governance blocks completion with unchanged committed state.
- LIFE-05: For completed/cancelled orders, technician edits fail. Supervisory edits require the documented advisory confirmation in UI and backend authorization; cancellation/reopening only follow approved transitions. Cover the full 6×6 status transition matrix with expected allow/deny and timestamp invariants.
- LIFE-06: Freeze time and independently compute SLA across multiple pauses, contractor/provider/both responsibility, pending review, resume, due-boundary, timezone and closed-order edit cases. Realtime and restart preserve stopwatch/history/KPI agreement.
- LIFE-07: Lost response, simultaneous start/pause/resume/approve and expired permission/session cannot leave request and order status inconsistent. Observe trigger/orchestration outcomes before any test-issued status write; never repair the result just to make the assertion pass.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** Pause/completion RPCs and request/order/history consistency; extend lifecycle integration suite using distinct ordinary actors. Inspect `lib/features/work_orders/data/`, relevant schema/rule files and `test/features/work_orders/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant LIFE persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `work_orders` data tests passed file by file (11 files, 185 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** Transition/authorization and SLA responsibility matrix from docs/business_rules.md, deterministic clock and independent arithmetic. Inspect `lib/features/work_orders/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable LIFE decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** Partial data validation on 2026-09-19: existing `work_orders` data tests passed file by file (11 files, 185 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** Details/pending-request/stopwatch state, approval/rejection and duplicate/racing actions. Inspect owning state implementations and `test/features/work_orders/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable LIFE cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `work_orders` data tests passed file by file (11 files, 185 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** Two-user technician-supervisor and provider-supervisor journeys; restart both sessions at each state boundary and compare server rows. Inspect `lib/features/work_orders/presentation/` and relevant routed/shared UI. Retain selected proposed real-app journeys for the later device-validation stage; execute these with recorded manual steps on the agreed platforms when that stage resumes.
- **Acceptance criteria:** Every required LIFE scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** Partial data validation on 2026-09-19: existing `work_orders` data tests passed file by file (11 files, 185 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.
