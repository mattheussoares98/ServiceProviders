# Step 23 — Offline sync, realtime, and interrupted operations

Dependencies: Data contracts in 03–22; feature-specific faults run earlier too. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- SYNC-01: For each SyncEntityType (workOrder, task, observation, pauseRequest, attachment, accessLog, checklistAnswer, changeRequest), queue a supported mutation offline, restart, reconnect and verify exact remote state plus empty/completed queue. Parent precedes children; create→update→delete and duplicate replay preserve intended final state.
- SYNC-02: Disconnect after remote commit before acknowledgement, kill during replay, retry transient errors and exhaust max attempts. No lost acknowledged write or duplicate row/history/file; failure remains visible and recoverable with original IDs.
- SYNC-03: Permission revoked, token expired, record deleted or company switched while queued. No replay under another user/tenant; the approved conflict policy determines reject/review/merge instead of silent overwrite.
- SYNC-04: Audit every internal registry fallback (locations/areas/categories/sectors/assets/SLA) for actual upload support. If an offline save reports success without a durable sync path, reproduce and file a data-loss bug; do not excuse it by calling the feature online-only after the fact.
- SYNC-05: Provider mode and Maintenance Plans stay online-only; no internal cache fallback/write/queue. Switch internal A → provider clients → internal A and verify physical cache/queue isolation.
- SYNC-06: Duplicate/out-of-order realtime events, disconnect/reconnect, delete tombstones and late old-company events converge to server state. Subscriptions are disposed on logout/mode changes; no event leak or unbounded connection growth.
- SYNC-07: Offline duration/pending limits/throttling and retry settings apply at boundaries. Cache clearing, disk full and app upgrade with a pending queue preserve or explicitly block unsafe operations; reconcile sync error/audit records.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** SyncEngine, queue repository/local/remote sources, Drift schema upgrade behavior, idempotency and durable recovery across every entity type. Inspect `lib/features/sync/data/`, relevant schema/rule files and `test/features/sync/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant SYNC persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `sync` data tests passed file by file (3 files, 24 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** Retry/backoff/limits, operation ordering, conflict policy and user/company ownership invariants. Inspect `lib/features/sync/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable SYNC decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** Partial data validation on 2026-09-19: existing `sync` data tests passed file by file (3 files, 24 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** Pending-count/sync-error and subscribing feature state, reconnect and stale-event protection; test one owning state area per turn. Inspect owning state implementations and `test/features/sync/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable SYNC cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `sync` data tests passed file by file (3 files, 24 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** Multi-device offline/online and interruption journeys; show queued/failed/committed distinction and usable retry with server evidence. Inspect `lib/features/sync/presentation/` and relevant routed/shared UI. Add focused widget tests and selected proposed `integration_test/` journeys; execute remaining cases with recorded manual steps on the agreed platforms.
- **Acceptance criteria:** Every required SYNC scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Format, targeted analysis and affected widget tests; execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** Partial data validation on 2026-09-19: existing `sync` data tests passed file by file (3 files, 24 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.
