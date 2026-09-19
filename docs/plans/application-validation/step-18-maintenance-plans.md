# Step 18 — Maintenance plans and generated work orders

Dependencies: 10–15. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- PLAN-01: Create plan with location/area/asset, internal/provider assignment, checklist, priority, currency/price, duration and lead time. Reload, edit/clear optional references, deactivate/reactivate and verify next due date and metadata. Invalid intervals, lead-time bounds and foreign/deleted references fail.
- PLAN-02: Test days/weeks/months/years and interval multipliers, weekday 1–7, month/day limits, Jan 31 → February, leap day, year rollover and UTC/local boundaries. Compare independently specified dates with both Dart calculation and deployed database calculation.
- PLAN-03: Manual generate → inspect returned order ID, preventive type, open status, copied fields/children, maintenance_plan_id, next_due_date and last-generated metadata. Denied user/foreign plan fails; permission combinations maintenance_plans.update/work_orders.create follow the approved contract.
- PLAN-04: On isolated scheduler fixtures only, execute due scan just before/at lead-time boundary, inactive/deleted/not-yet-due cases, overdue catch-up and failing plan alongside a valid plan. Check last_error and successful recovery. Inspect actual cron schedule, don't infer deployment from local docs.
- PLAN-05: Concurrent scheduled/manual triggers and retry after lost response must obey the agreed generation/idempotency contract. Distinguish a repeated request for the same occurrence from a deliberate new manual generation; assert no unintended duplicate occurrence or skipped due date.
- PLAN-06: Delete with open generated order must be rejected; completed/cancelled orders use the maintenance-specific exception. Eligible soft delete survives reload and stops generation while history remains linked. Offline create/edit/delete/generate must fail clearly and enqueue nothing.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** Remote CRUD/generate RPC, deployed recurrence trigger and scheduler, reference guards and atomic generation; new live suite proposed. Inspect `lib/features/maintenance_plans/data/`, relevant schema/rule files and `test/features/maintenance_plans/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant PLAN persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `maintenance_plans` data tests passed file by file (2 files, 11 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** CalculateNextDueDateUseCase and scheduling boundaries, assignments/permissions and online-only mutation contract. Inspect `lib/features/maintenance_plans/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable PLAN decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** 2026-09-19: Maintenance-plan use-case file: 24 passed; targeted analysis passed. Thirteen new recurrence cases cover leap years, year rollover, UTC offset boundaries, weekday anchors, and repeated monthly clamping. Database parity, malformed-input validation, and remaining domain cases are outstanding. See [per-file commands and results](../../testing/runs/2026-09-19-domain-state-widget.jsonl).

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** MaintenancePlansCubit create/update/delete/generate state, duplicate clicks, missing generated order and refreshed due date. Inspect owning state implementations and `test/features/maintenance_plans/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable PLAN cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `maintenance_plans` data tests passed file by file (2 files, 11 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** Plan list/form/generate controls and generated-order navigation, full PERSIST, recurrence presentation and offline feedback. Inspect `lib/features/maintenance_plans/presentation/` and relevant routed/shared UI. Add focused widget tests and selected proposed `integration_test/` journeys; execute remaining cases with recorded manual steps on the agreed platforms.
- **Acceptance criteria:** Every required PLAN scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Format, targeted analysis and affected widget tests; execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** Partial data validation on 2026-09-19: existing `maintenance_plans` data tests passed file by file (2 files, 11 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.
