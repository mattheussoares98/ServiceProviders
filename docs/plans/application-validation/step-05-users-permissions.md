# Step 05 — Users, invitations, and permissions

Dependencies: 04. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- USR-01: Create a private permission group, update actions/scopes, assign a disposable user and reload. Check explicit allow, explicit deny, inherited/absent grants, supported wildcard/legacy representation and per-user overrides without dropping unrelated permission keys.
- USR-02: TECH_A attempts to edit its own group, admin flag, company and permissions or another profile through API/RPC. Deny escalation and verify unchanged data. USER_B cannot read/modify company A profiles/groups. An ordinary admin's broad rights stay inside A.
- USR-03: Exercise work-order read all/assigned and update all/assigned/own/none; revoked rights must affect fresh requests and cached UI according to the confirmed refresh contract. Provider mode ignores internal admin/group privileges.
- USR-04: With explicit mail authorization: invite → list pending → resend → accept; also expired, duplicate, already-used and wrong-account acceptance. Revoke a pending invite and retry its link. Compare confirmed-user soft deletion/deactivation with pending-invitation revocation exceptions.
- USR-05: Edit profile/avatar; cancel and fail a save; remove/deactivate an eligible test user and reload. Attempt removal of an in-use group, last/required admin, or an assigned user according to the approved rules. Verify references and access after removal, and restore fixture grants.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** User/group DTO preservation, profile/group RLS and invitation Edge Function caller/tenant checks; pending versus confirmed deletion semantics. Inspect `lib/features/users/data/`, relevant schema/rule files and `test/features/users/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant USR persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `users` data tests passed file by file (5 files, 71 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** HasPermissionUseCase, permission overrides and read/update scopes; provider gate precedes internal admin overrides. Inspect `lib/features/users/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable USR decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** Partial data validation on 2026-09-19: existing `users` data tests passed file by file (5 files, 71 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** User list, invitations, group and per-user permission editor state; refresh and failure rollback. Inspect owning state implementations and `test/features/users/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable USR cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `users` data tests passed file by file (5 files, 71 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** Users/permissions editors and invitations with independent actors; verify hidden controls plus direct denied requests. Inspect `lib/features/users/presentation/` and relevant routed/shared UI. Add focused widget tests and selected proposed `integration_test/` journeys; execute remaining cases with recorded manual steps on the agreed platforms.
- **Acceptance criteria:** Every required USR scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Format, targeted analysis and affected widget tests; execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** Partial data validation on 2026-09-19: existing `users` data tests passed file by file (5 files, 71 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.
