# Remaining validation coverage

Updated: 2026-09-19, after removing new widget tests from scope. This is a coverage-gap summary, not a claim that every listed feature lacks existing tests. Existing tests need to be reconciled against the planned cases before adding missing coverage.

## Current authorized work

1. **Domain rules across features.** Expand and execute boundary/error cases for authentication/session selection, company settings, users, registries, assets, providers, checklists, work orders, notifications, settings, and dashboard calculations. Location/area error propagation and maintenance recurrence have partial executed coverage. Invalid recurrence input and other business decisions remain outstanding.
2. **Cubit/state behavior.** Validate loaded-data preservation after failed writes, retries, optional-value clearing, loading/error sections, reloads after CRUD, list/detail consistency, and subscription disposal. Location state has partial executed coverage; most other feature state plans remain unvalidated in this campaign.
3. **Remaining CRUD/persistence contracts.** Map existing data tests and new local persistence tests against every feature's scenarios. Fill actual gaps in failure propagation, dependent deletion, restore/deactivation, filters, and cache consistency. Broad local persistence coverage already exists; do not duplicate it just to raise counts.
4. **Work-order business flows.** Cover the status transition matrix, pause/resume, completion approval/rejection, mandatory checklist/evidence rules, assignments, tasks, observations, and related failure invariants at the domain/state layers. Local lifecycle persistence alone does not establish those rules.
5. **Final non-widget regression review.** Run relevant files individually, record results before the next file, keep failing regressions enabled, and reconcile case coverage and known defects. Production fixes remain out of scope.

## Deferred release-validation gaps

- Live CRUD and independently authenticated reloads using the configured ordinary accounts; company isolation and role/provider access checks.
- Readiness blockers: password parsing (VAL-001), supervisor permission configuration (VAL-002), and runner-report parsing (VAL-003).
- Actual offline reconnect/replay and app restart behavior; scheduled maintenance generation and database/Dart recurrence parity.
- Real attachment upload/download, device notifications, and supported-device user journeys. External email/push actions retain their explicit authorization requirements.

These deferred gaps prevent claiming full application validation. They are not instructions to resume live/security/device work now. New widget-test creation is excluded; manual real-app checks remain separate.

## Completion rule

No feature is yet fully validated against its remaining acceptance criteria. Keep its step file until coverage and required checks are complete. A known defect stays in the [findings list](../../testing/validation_findings.md) for future fixes; do not change production code to make a regression pass.
