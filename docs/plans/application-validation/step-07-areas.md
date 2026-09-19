# Step 07 — Areas within locations

Dependencies: 06; asset/work-order reference cases use verified Step 02 fixture builders, with full user flows repeated in 11/14/24. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- AREA-01: Create an area inside location L1, rename, reload in a second session, and delete an eligible area with PERSIST. Verify its company and location IDs at every stage.
- AREA-02: Change selected location L1 → L2 while an area/asset is selected. Invalid child selections clear or are rejected; no hidden save retains an area from another location/company.
- AREA-03: Duplicate names within one location and across two locations follow the confirmed uniqueness rule. Blank names, deleted/missing parent, parent deleted during editing, and forged company/location IDs cannot produce orphan data.
- AREA-04: Attempt deletion/reparenting with linked assets and orders. Record the deployed rule and verify links/history remain consistent; do not assume a location guard also protects areas.
- AREA-05: Provider can read allowed contracting-company area lookups, not mutate them. Internal offline create/update/delete followed by reconnect must expose the same persistence guarantee as locations.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** Area request/response models and local/remote sources under locations; extend area integration suite with relationships and tenant cases. Inspect `lib/features/locations/data/`, relevant schema/rule files and `test/features/locations/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant AREA persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `locations` data tests passed file by file (5 files, 81 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** Area/location relationship, lookup scoping and input validation. Inspect `lib/features/locations/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable AREA decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** 2026-09-19: `flutter test --no-pub test/features/locations/domain/use_cases/use_cases_test.dart --reporter expanded` passed 34 tests; targeted analysis passed. Six new contracts preserve write failure details. Input validation, business-rule boundaries, and full feature acceptance remain incomplete.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** Area create/update/list state and dependent-selector invalidation. Inspect owning state implementations and `test/features/locations/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable AREA cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `locations` data tests passed file by file (5 files, 81 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** Area form inside location workflows; back/cancel/reload, move/delete dependency and stale-parent cases. Inspect `lib/features/locations/presentation/` and relevant routed/shared UI. Add focused widget tests and selected proposed `integration_test/` journeys; execute remaining cases with recorded manual steps on the agreed platforms.
- **Acceptance criteria:** Every required AREA scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Format, targeted analysis and affected widget tests; execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** 2026-09-19: Area creation-form widget file: 3 passed, 1 failed; targeted analysis passed. Covers empty/whitespace names, failed-create retry with full field/location preservation, and back navigation. VAL-011 remains failing; edit/delete and live journeys remain incomplete. See [per-file commands and results](../../testing/runs/2026-09-19-domain-state-widget.jsonl).
