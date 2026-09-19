# Application validation execution — 2026-09-19

Scope: data tests, supporting test infrastructure, and incremental domain/state/widget coverage. Checkout: `a50dc25eaf94ddb8c40adcdd101f861b418965e4` plus the working changes recorded by each source digest. Tests run one file at a time; the dated status is written before the next file starts. Completion comments do not disable regression execution.

This is partial validation, not a release approval or full feature completion. The application, database schema, live permissions, and `.env` were not changed. Confirmed defects remain unfixed, and their regression assertions remain enabled and failing. Read the [durable findings](validation_findings.md) before interpreting the results.

## Recorded results

- Existing feature data baseline: **71 files, 828 passed**. [Per-file results](runs/2026-09-19-data-files.jsonl).
- New persistence and failure-contract coverage: **19 files, 67 passed, 21 failed**. [Persistence records](runs/2026-09-19-persistence.jsonl), [repository contract records](runs/2026-09-19-write-contracts.jsonl).
- Core data/client baseline: **15 files, 157 passed, 0 failed**. [Per-file records](runs/2026-09-19-core-data-files.jsonl).
- Test infrastructure: accounts 16/16, recovery 5/5, modeled runner summaries 10/10 passed. Real Flutter output later exposed the additional runner-envelope defect VAL-003; those ten passing modeled cases do not establish full reporter correctness. The new [daemon regression file](../../test/integration_support/integration_run_summary_daemon_test.dart) now reproduces it: 2 passed, 1 failed; [run record](runs/2026-09-19-reporter-regression.jsonl).
- Live readiness: 0/13 passed; credential parsing blocked every case (VAL-001). Direct authenticated read-only probes had established five ordinary accounts across the two configured companies. Supervisor grants require reconciliation (VAL-002). No live business records were created, updated, or deleted.

## New file coverage

| Test file | Passed | Failed | What it validates |
| --- | ---: | ---: | --- |
| [locations_persistence_test.dart](../../test/local_integration/locations_persistence_test.dart) | 5 | 0 | Location/area CRUD, nullable fields, company filters, repeated upserts, tombstones after reopening |
| [categories_persistence_test.dart](../../test/local_integration/categories_persistence_test.dart) | 3 | 0 | Category CRUD, optional clears, company filters, batch replay and tombstones |
| [sectors_persistence_test.dart](../../test/local_integration/sectors_persistence_test.dart) | 3 | 0 | Sector CRUD, company filters and tombstones |
| [sla_persistence_test.dart](../../test/local_integration/sla_persistence_test.dart) | 3 | 0 | SLA target/scope changes, deletion and company filters |
| [assets_persistence_test.dart](../../test/local_integration/assets_persistence_test.dart) | 4 | 0 | Asset CRUD, moving areas, deleted ancestors, hierarchy links and replay |
| [sync_recovery_persistence_test.dart](../../test/local_integration/sync_recovery_persistence_test.dart) | 4 | 1 | Queue ordering/ownership, interrupted sync, dead-letter retry, acknowledgement and cancellation isolation |
| [checklists_persistence_test.dart](../../test/local_integration/checklists_persistence_test.dart) | 3 | 1 | Template/item lifecycle, re-answering without duplicates and bulk-write failure propagation |
| [work_orders_persistence_test.dart](../../test/local_integration/work_orders_persistence_test.dart) | 4 | 0 | Order edit/delete/restore, status filtering, company filters and task completion/reopening |
| [attachments_persistence_test.dart](../../test/local_integration/attachments_persistence_test.dart) | 3 | 0 | Attachment metadata, upload states/recovery paths, deletion and eviction eligibility; not binary file upload |
| [service_providers_persistence_test.dart](../../test/local_integration/service_providers_persistence_test.dart) | 4 | 0 | Provider/profile lifecycle, company filters and atomic rejection of conflicting documents |
| [company_persistence_test.dart](../../test/local_integration/company_persistence_test.dart) | 3 | 0 | Company settings, limits, empty/false values and per-company parameters |
| [users_persistence_test.dart](../../test/local_integration/users_persistence_test.dart) | 3 | 0 | Profile lifecycle, persisted explicit allow/deny overrides and grant replacement |
| [pause_lifecycle_persistence_test.dart](../../test/local_integration/pause_lifecycle_persistence_test.dart) | 5 | 0 | Pause/resume, completion approval/rejection, transaction rollback and pause reasons |
| [session_settings_persistence_test.dart](../../test/local_integration/session_settings_persistence_test.dart) | 4 | 2 | Preference persistence, session replacement/logout and settings storage failures |
| [observations_persistence_test.dart](../../test/local_integration/observations_persistence_test.dart) | 3 | 0 | Observation CRUD, batch replay, per-order scoping and provider author identity |
| [maintenance_plan_cache_persistence_test.dart](../../test/local_integration/maintenance_plan_cache_persistence_test.dart) | 2 | 0 | Existing plan cache schedule changes, nullable fields, company filters and deletion; not scheduler execution |
| [sync_dead_letter_isolation_test.dart](../../test/local_integration/sync_dead_letter_isolation_test.dart) | 1 | 2 | Failed-item lookup/retry isolation and preservation of structured child references |
| [locations_write_contract_test.dart](../../test/features/locations/data/repositories/locations_write_contract_test.dart) | 2 | 12 | Six mutation paths: mirror failure and unsupported offline write; remote-denial metadata |
| [maintenance_plans_failure_contract_test.dart](../../test/features/maintenance_plans/data/repositories/maintenance_plans_failure_contract_test.dart) | 8 | 3 | Generation/detail online/offline behavior, empty responses and error metadata |

## Commands and evidence limits

Each ordinary file uses `env -u INTEGRATION_TESTS flutter test --no-pub <one-file> --reporter expanded`. New Dart files were formatted and analyzed individually before the final execution. Each JSONL row references the source body digest, result, and available log. Build logs under `build/file-validation/` are disposable; committed tests, this report, JSONL counts, and the defect reproductions are the durable evidence. Locations' first new run was captured in the tool output rather than a disk log, as its record states.

On-disk tests close the SQLite connection and construct fresh data sources against the same temporary database. This checks durable local persistence, not a full process kill, UI navigation, mobile background recovery, remote persistence, or RLS. Tests use generated local fixtures; live database testing uses only configured test accounts. Attachment paths and session tokens in local tests are synthetic. Fault injection uses only disposable local connections/triggers.

Draft-test assumptions were corrected after checking independent contracts: attachment local paths are persisted as filenames and resolved by FileService; provider fixtures require distinct documents under the current unique constraint. Provider-author fixtures also use the actual joined `provider_author` response shape. A separate test now verifies atomic rejection of duplicate documents. These were test-authoring issues, not application fixes; they are not counted as confirmed product defects. Initial draft compilation/lint errors likewise do not count as executed behavioral evidence.

## Remaining gates

- Resolve live-test setup/report blockers before dependent live tests. This task's no-fix instruction leaves VAL-001 through VAL-003 unchanged. Credential values must never appear in reports.
- Validate live schema/RLS and supported-platform real-app journeys before claiming feature completion. Actual external upload, email and push delivery have not been tested.
- On 2026-09-19 the user authorized CRUD, persistence, domain, state, and widget work across layers. Location domain/state/form coverage has begun; other features and outstanding scenarios remain incomplete. Live/security/recovery execution is deferred under the current scope.
- Keep feature step plans until all their required coverage is executed and the applicable completion criteria are met. None is fully covered yet, so none has been deleted. Failed regression tests are expected to make the ordinary suite fail until separately authorized product fixes land.

## Continued domain, state, and widget coverage — 2026-09-19

Executed sequentially, recording each file before starting the next. See [per-file records](runs/2026-09-19-domain-state-widget.jsonl).

- Location/area use cases: 34 passed, including six new write-error metadata contracts.
- Location state: 38 passed, including three new create/update retry and rejected-delete preservation cases.
- Location creation form: 3 passed, 2 failed. Empty-name rejection, failed-save/retry, and cancellation pass. Whitespace-name validation and late address overwrite fail (VAL-011, VAL-012).
- Targeted analyses passed. Widget tests use Android rendering and mocked Cubits, not a device or live backend. Initial test-platform teardown and mock setup errors were corrected before recording the final run; no application fix was made.
- Small commits group coverage by feature and infrastructure purpose. Temporary validation headers remain only in the working tree, including on newly committed files. Persistent results live in this report and JSONL records.

- Area creation form: 3 passed, 1 failed. Required-name rejection, retained fields/location across failed-create retry, and abandoning edits are covered; whitespace submission also reproduces VAL-011. The draft back-navigation finder was corrected to target the app's actual arrow button.
- Maintenance-plan use cases: 24 passed, including 13 new calendar cases for leap years, year rollover, long intervals, weekday anchors, UTC offset boundaries, and restoring the 31st after February. These verify Dart calculations only; database recurrence parity and invalid-input validation remain outstanding.
- Continuation total: **5 files, 102 passed, 3 failed**; **31 added cases** (28 passed, 3 failed). No additional live or reporter tests were run in this continuation.
