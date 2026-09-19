# Step 12 — Service providers and provider mode

Dependencies: 05–11; execution handoffs finish in 14–17. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- SP-01: Create/update a provider company and profile, reload, deactivate/reactivate a profile where supported, and verify availability in assignment pickers. Do not invent provider-company deletion if no action is exposed; record N/A and the supported lifecycle.
- SP-02: With mail authorization: invite → accept with correct account → reload; test duplicate email, expired/revoked/reused token, wrong signed-in account and resend/revoke where implemented. No acceptance may attach the user to an attacker-selected company.
- SP-03: Provider-only account signs in, selects among permitted contracting companies, and sees only the allowed orders/lookups. Direct known-ID access to unrelated orders/company B and forged RPC/Edge requests fail.
- SP-04: Deactivate membership or remove assignment during an active session; verify fresh API calls and UI refresh lose the intended access. Contracting-company lookups can be broader than assigned order assets; assert each documented scope explicitly.
- SP-05: Dual-mode internal admin/supervisor acts as provider: no approval, financial management, reassignment, registry editing or observation-history deletion merely because internal rights exist.
- SP-06: Provider offline list/detail/create/mutations fail clearly without Drift fallback, queueing or writing client-company rows into the internal cache. Retry after reconnect remains in the intended company.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** Provider-company/profile/invitation sources, active membership resolution, invitation function and per-resource access; separate provider credentials. Inspect `lib/features/service_providers/data/`, relevant schema/rule files and `test/features/service_providers/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant SP persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `service_providers` data tests passed file by file (4 files, 58 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** Provider session resolution and providerModeAllows capability matrix; creation company-parameter gate. Inspect `lib/features/service_providers/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable SP decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** Partial data validation on 2026-09-19: existing `service_providers` data tests passed file by file (4 files, 58 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** Provider/company lists, invitation acceptance and mode-switcher state including lost membership and stale subscriptions. Inspect owning state implementations and `test/features/service_providers/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable SP cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `service_providers` data tests passed file by file (4 files, 58 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** Provider registration/invitation and provider home journeys; actual assigned execution is covered with work-order steps. Inspect `lib/features/service_providers/presentation/` and relevant routed/shared UI. Add focused widget tests and selected proposed `integration_test/` journeys; execute remaining cases with recorded manual steps on the agreed platforms.
- **Acceptance criteria:** Every required SP scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Format, targeted analysis and affected widget tests; execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** Partial data validation on 2026-09-19: existing `service_providers` data tests passed file by file (4 files, 58 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.
