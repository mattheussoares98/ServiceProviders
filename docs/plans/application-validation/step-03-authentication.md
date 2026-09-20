# Step 03 — Authentication, sessions, and navigation

Dependencies: 01–02. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- AUTH-01: Valid and invalid login, blank/invalid email and password, rapid double submit, server timeout, and retry. No duplicate session/navigation or stale error; signed-out users cannot reach protected data by deep link.
- AUTH-02: Login → restart/hard refresh → protected route → token refresh → logout → browser/device back. Correct session restoration; logged-out cached content and realtime events cannot reveal the former user's data.
- AUTH-03: Internal-only, provider-only, and dual-mode users choose only valid modes. Changing mode clears incompatible selections; company-less or inactive users get the expected onboarding/denial, not a redirect loop.
- AUTH-04: On controlled mailboxes with delivery authorization, exercise signup, confirmation/OTP, expired/reused/invalid links, password reset and password change; wrong current password and replayed links fail. Verify the deployed session-invalidation contract after password change.
- AUTH-05: Session expires while saving or offline; recover through login without silently losing a draft or submitting it under a different identity. Cross-account relogin starts with the new user's data only.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** Authentication response/error mapping, session storage, and remote/local clearing; per-user token binding and auth-route guards. Inspect `lib/features/auth/data/`, relevant schema/rule files and `test/features/auth/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant AUTH persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `auth` data tests passed file by file (5 files, 51 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** Login/OTP/password validation and selected-mode/company resolution; no fabricated membership on missing profiles. Inspect `lib/features/auth/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable AUTH decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** Partial data validation on 2026-09-19: existing `auth` data tests passed file by file (5 files, 51 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** Session, login, mode-switcher and splash Cubits: one transition per action, expired session, stale async callbacks and retry. Inspect owning state implementations and `test/features/auth/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable AUTH cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `auth` data tests passed file by file (5 files, 51 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** Login/signup/confirmation/change-password/mode screens, deep links and back navigation; run restart journeys in both app modes. Inspect `lib/features/auth/presentation/` and relevant routed/shared UI. Retain selected proposed real-app journeys for the later device-validation stage; execute these with recorded manual steps on the agreed platforms when that stage resumes.
- **Acceptance criteria:** Every required AUTH scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** Partial data validation on 2026-09-19: existing `auth` data tests passed file by file (5 files, 51 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.
