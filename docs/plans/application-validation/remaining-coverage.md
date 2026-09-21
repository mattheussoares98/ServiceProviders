# Remaining validation gaps (Post-step-execution)

Updated: 2026-09-20. All 24 local feature step plans (CRUD, persistence contracts, domain, cubit/state, and routing guard regressions) have been executed, their regressions enabled, and their findings catalogued in [validation findings](../../testing/validation_findings.md) (VAL-001 through VAL-060).

The following gaps remain outside the completed local automated test campaign:

## Deferred release-validation gaps

1. **Live database authentication & RLS enforcement**
   - Independent verification with ordinary configured accounts (ADMIN_A, SUPERVISOR_A, TECH_A, PROVIDER_A, USER_B) across isolated test companies A and B.
   - Requires resolving live readiness blockers: password parsing with dotenv interpolation ([VAL-001](../../testing/validation_findings.md#val-001--live-test-environment-parsing-changes-unquoted-passwords)) and supervisor permission naming reconciliation ([VAL-002](../../testing/validation_findings.md#val-002--supervisor-setup-does-not-match-application-permission-names)).

2. **Test reporter daemon envelope support**
   - Resolving Flutter machine daemon envelope parsing in `tool/integration_run_summary.dart` ([VAL-003](../../testing/validation_findings.md#val-003--integration-report-treats-a-flutter-daemon-event-as-malformed)).

3. **Live sync engine replay and offline recovery**
   - Real network toggling, mobile process lifecycle termination/restart, and actual Supabase/Drift bidirectional sync verification under flaky connectivity.
   - Deployed database recurrence parity and scheduler execution for maintenance plans.

4. **External services & hardware capabilities**
   - Real binary file upload/download via Cloudflare R2 / presigned URLs.
   - Push notification delivery via FCM/APNs and email delivery verification with explicit test recipients.
   - Supported release platform checks on physical iOS and Android hardware.

## Production defect fixes

All 58 catalogued product defects ([VAL-003](../../testing/validation_findings.md#val-003--integration-report-treats-a-flutter-daemon-event-as-malformed) through [VAL-060](../../testing/validation_findings.md#val-060--companyguard-redirects-to-loginroute-when-companyid-is-whitespace-only)) have been fixed in production code, with all 2,246 regression tests passing green. Only VAL-001 and VAL-002 remain as setup prerequisites for live staging tests.
