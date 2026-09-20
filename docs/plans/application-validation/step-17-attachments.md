# Step 17 — Attachments and file recovery

Dependencies: 04 and 14; checklist attachment variants use 13. Actors: the applicable ordinary accounts in [accounts-and-environment.md](accounts-and-environment.md); privileged smoke results remain separate.

## Scenarios and expected results

- FILE-01: Pick/capture image, video, PDF, DOCX and XLSX, upload, preview/open, restart and open from a second authorized device. Compare file identity/content and metadata, not just a thumbnail. Cancel picker/upload and retry failure without ghost rows.
- FILE-02: At-limit and one-byte-over-limit original files, unsupported/uppercase/double extensions, corrupt/zero-byte and mismatched content; use configured limits plus actual platform rules. Current defaults differ for web/mobile images and videos; compression must not bypass original-size validation.
- FILE-03: Network fails before presigning, mid-upload, after R2 success before metadata save and after commit before response. Restart/resume/retry produces one valid attachment or a clearly recoverable failure; track orphan objects. Duplicate hash/reupload and restore of deleted attachment follow the intended deduplication scope.
- FILE-04: Soft-delete/cancel delete, fresh-read absence, historical references and object cleanup follow the serving/retention contract. Deny presigned-upload/metadata access for foreign order/company/object IDs; test actual download URLs, expired signatures and path tampering against the implemented access model.
- FILE-05: Gallery/camera/storage permissions allowed/denied/revoked, unavailable open-file application, disk full and sandbox quota/pruning. Pending uploads survive safe cache actions. Provider files stay within assigned execution scope and never populate internal cross-company cache.

Expand these families into atomic case IDs in the run record. Apply [PERSIST, PERM and FAULT](validation-protocol.md) wherever applicable; record evidence-based N/A for unsupported operations. Setup fixtures must be run-owned. Cases needing later features stay blocked until those dependencies are validated.

## Phase 1 — Data and database behavior

- [ ] Complete
- **Layer:** Data.
- **Actions/files:** Attachment local/remote repository, generate_presigned_url and cleanup-attachments functions, R2 upload/metadata consistency and exact-object cleanup. Inspect `lib/features/attachments/data/`, relevant schema/rule files and `test/features/attachments/data/`; add missing test files only after approval. Plan live cases in `test/integration/tests/` using the guarded infrastructure; no schema fixes are implied.
- **Acceptance criteria:** Relevant FILE persistence, failure and authorization cases pass against independent reads; server/client contracts and local/remote ownership agree. Required missing identities or unverified schema leave this phase blocked.
- **Validation:** Format changed tests; targeted analysis and affected data tests with live opt-in absent. Then, only with live authorization and Steps 01–02 complete, run the reviewed feature integration suite serially and reconcile case counts, report and exact-ID cleanup. Record denied-state invariants and persistence evidence.
- **Evidence:** Partial data validation on 2026-09-19: existing `attachments` data tests passed file by file (3 files, 68 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 2 — Domain rules

- [ ] Complete
- **Layer:** Domain.
- **Actions/files:** AttachmentFileValidator, original-size/type boundaries, hash scope, pruning eligibility and upload state transitions. Inspect `lib/features/attachments/domain/` and existing domain tests; add deterministic boundary/error cases using shared factories. Related domain helpers may belong to another feature; record their exact ownership before editing.
- **Acceptance criteria:** Applicable FILE decisions and boundary rules match an independent business oracle; malformed input, denied roles and failure paths are covered without live network. Ambiguous rules remain blocked until resolved.
- **Validation:** Format changed files; targeted analysis and affected domain tests with live opt-in absent; record expected-vs-actual boundary cases, not just compilation.
- **Evidence:** Partial data validation on 2026-09-19: existing `attachments` data tests passed file by file (3 files, 68 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 3 — Cubits and state

- [ ] Complete
- **Layer:** Cubits/state.
- **Actions/files:** Attachment processing/upload/retry/delete state, progress and pending local files after restart. Inspect owning state implementations and `test/features/attachments/presentation/`; read BaseCubit/BaseState contracts before adding bloc_test expectations. Cover only state owners relevant to this feature.
- **Acceptance criteria:** Loading → success/error and data/rollback agree with all applicable FILE cases; duplicate actions and stale callbacks do not create false success, duplicate rows or leaked old-session state.
- **Validation:** Format, targeted analysis and owning Cubit/state tests with mocked clients. Assert section status/data/error and subscription disposal as applicable, using deterministic event ordering.
- **Evidence:** Partial data validation on 2026-09-19: existing `attachments` data tests passed file by file (3 files, 68 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.

## Phase 4 — UI and realistic user flows

- [ ] Complete
- **Layer:** UI validation.
- **Actions/files:** Picker/camera/preview/open-file on supported real platforms, slow upload interruption and fresh-device viewing; use harmless generated fixture files. Inspect `lib/features/attachments/presentation/` and relevant routed/shared UI. Retain selected proposed real-app journeys for the later device-validation stage; execute these with recorded manual steps on the agreed platforms when that stage resumes.
- **Acceptance criteria:** Every required FILE scenario passes in the real app, including restart/second-session checks for accepted mutations, permission denials, empty/loading/error/retry and relevant accessibility/layout checks. No open critical feature defect or silently skipped prerequisite.
- **Validation:** Execute the recorded real-app command/manual journey with sanitized UI and authenticated-read evidence. Verify run-owned cleanup and reopen earlier phases if new defects invalidate them.
- **Evidence:** Partial data validation on 2026-09-19: existing `attachments` data tests passed file by file (3 files, 68 cases). See [execution report](../../testing/application_validation_progress.md) for new persistence/fault cases and [findings](../../testing/validation_findings.md) for failures. Command: `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. Live/schema/authorization acceptance remains unvalidated or blocked; phase stays unchecked.
