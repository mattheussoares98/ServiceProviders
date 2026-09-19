# Step 02 — Test harness, reporting, and recovery

Dependencies: Step 01. Scope: test infrastructure; production behavior changes require separate approval. Complete this step before running the existing live mutation suites.

## Phase 1 — Make test results and cleanup dependable

- [ ] Complete
- **Layer:** Data/test infrastructure.
- **Actions/files:** Review and extend `test/integration/core/`, `tool/run_integration_tests.sh`, `tool/build_integration_report.dart`, and `testing/mocks/`. Preserve opt-in guards and serial execution. Keep recovery ledgers outside report directories erased by the runner; retain failed recovery entries and exact unresolved fixture IDs. Propagate Flutter/report failures and reconcile all cases, including plain `test()` suites, setup failures, and explicit skips. Separate delete assertions from the cleanup toggle. Use run-owned fixtures and disable existing-data reuse for writes. Add ordinary identities with separate clients; privileged setup may create fixtures, but tested actions must use the named actor. Never grant TECH administrative fixture permissions merely to make setup pass.
- **Acceptance criteria:** A failed test, empty/incomplete expected suite, blocked required identity, report failure, or unrecovered fixture cannot appear as a fully passing run. Reports and ledgers survive process interruption. Test cleanup cannot sweep another run's data. Minimal dependency builders verify company/parent IDs and return persisted IDs; they provide fixtures for later features without claiming those features passed. No password/token is logged or packaged into a distributed test/release build.
- **Validation:** Local fake-runner tests for pass/fail/zero-case/setup/report errors; mock restoration failure and process-restart recovery; verify default test discovery makes no live connection; format changed Dart, targeted analysis and infrastructure tests. Review configuration asset separation and track any production build fix in its own approved scope. Then run one authorized staging smoke case with exact-ID cleanup and an independently checked result.
- **Evidence:** Partial implementation/validation on 2026-09-19: accounts 16/16, durable recovery 5/5 and modeled result-summary 10/10 local cases passed individually; their headers record commands. The real readiness run surfaced additional reporter envelope handling (VAL-003) and credential parsing (VAL-001) blockers, so this phase is not complete. No mutation cleanup smoke has run. See [current report](../../testing/application_validation_progress.md).

## Phase 2 — Record the offline automated baseline

- [ ] Complete
- **Layer:** Test infrastructure validation; no production edits.
- **Actions/files:** Inventory existing unit/widget/contract cases and relevant coverage using `test/` and `testing/mocks/`. Add a case-to-feature manifest and retain baseline artifacts under this plan's run record. Keep live opt-in absent. Document pre-existing failures without weakening assertions.
- **Acceptance criteria:** Actual case count, failures, skipped live files, and coverage gaps are recorded against a commit; a historical green report is not reused as current evidence. Default tests cannot contact the real project. Missing generated output is reported without running build_runner.
- **Validation:** `flutter analyze testing/mocks test`; `env -u INTEGRATION_TESTS flutter test --coverage`, after verifying no live Dart defines/config flags. Inspect coverage of critical branches rather than adopting a percentage as proof. Investigate failures before dependent checks.
- **Evidence:** Partial baseline on 2026-09-19: 71 feature data files passed 828 cases and 15 core data/client files passed 157 cases, one file at a time. Dated file headers and JSONL evidence are linked in the [execution report](../../testing/application_validation_progress.md). New fault tests also expose product failures. Domain/state/UI baseline and coverage collection remain outstanding, so this phase stays unchecked. The user’s serial-file rule replaces the planned all-suite invocation.

## Phase 3 — Establish the real-app journey harness

- [ ] Complete
- **Layer:** UI test infrastructure (separate turn from data infrastructure).
- **Actions/files:** Add a minimal proposed `integration_test/` harness using installed Patrol/Flutter capabilities. Discover runner options via installed help; confirm entrypoint/flavor and device. Provide isolated app profiles, stable finders, bounded waits on observable states, screenshots on failure, and independent authenticated read probes. Implement one login → list → restart smoke journey; browser testing may remain manual until a compatible runner is verified.
- **Acceptance criteria:** A real installed/running app is driven on one agreed platform; a restart destroys transient screen state; failure produces evidence without exposing credentials. The harness never silently changes user or project and cannot send unsolicited email/push.
- **Validation:** Record the exact platform command and smoke result; induce a controlled assertion failure to verify truthful reporting and evidence. Confirm default `flutter test` still excludes live work.
- **Evidence:** Not run. Record command/check, result, date, and run link.
