# Step 19 — Notifications and device tokens

Dependencies: 03 and 14–16; explicit test-device delivery authorization. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- NOTIF-01: Register/update device token, restart, rotate token and log out. Duplicate registration does not multiply recipients; logout removes the relevant association and another user's login does not inherit notifications.
- NOTIF-02: On approved devices, create assignment/reassignment, pause/completion requests and reviews, and observations. Check intended recipients, exclusion of actor, deduplication and company isolation. Compare stored dispatch evidence with actual receipt; neither alone proves the full flow.
- NOTIF-03: Receive/tap in foreground, background and terminated app; correct order route after login. Deleted/inaccessible order or revoked membership must show denial rather than stale private content.
- NOTIF-04: Permission denied/revoked, notification preference off, expired token and delivery-provider failure. Core save must follow the confirmed contract and show accurate outcome; retries must not spam recipients.
- NOTIF-05: Reject forged device ownership, unauthorized send-function calls and arbitrary foreign recipient IDs. Payloads contain no credentials or unnecessary sensitive detail.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** Device-token repository, dispatch triggers and send-push-notification caller/recipient checks; mock delivery in ordinary tests. Inspect `lib/features/notifications/data/`, relevant schema/rule files and `test/features/notifications/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant NOTIF persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `notifications` data tests passed file by file (2 files, 10 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** Token ownership and registration/deletion use cases; recipient/preference contract with deterministic expected users. Inspect `lib/features/notifications/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable NOTIF decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** Partial data validation on 2026-09-19: existing `notifications` data tests passed file by file (2 files, 10 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** Notification-client/session lifecycle and navigation handlers (inspect actual owners before adding tests); deduplication and stale-session events. Inspect owning state implementations and `test/features/notifications/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable NOTIF cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `notifications` data tests passed file by file (2 files, 10 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** Native/web supported notification capability and deep-link journey; record unsupported platforms explicitly and never replace device checks with mock-only claims. Inspect `lib/features/notifications/presentation/` and relevant routed/shared UI. Retain selected proposed real-app journeys for the later device-validation stage; execute these with recorded manual steps on the agreed platforms when that stage resumes.
- **Acceptance criteria:** Every required NOTIF scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** Partial data validation on 2026-09-19: existing `notifications` data tests passed file by file (2 files, 10 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.
