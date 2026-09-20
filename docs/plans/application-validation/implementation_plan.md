# Application validation plan

Created: 2026-09-19. Status: **implementation approved; executing test files sequentially**.

## Objective

Find reproducible defects in real user journeys and establish repeatable regression checks across ServicePro. Verify that successful actions actually persist, denied actions cannot change data, company and provider boundaries hold, and interrupted operations recover correctly. Tests reduce risk; a passing suite is not a guarantee that the application has no bugs.

## Scope and strategy

**Current scope:** automated CRUD, local persistence, domain, and Cubit/state tests. Do not create additional widget tests; they are not a completion requirement. Existing results remain historical evidence. Live database/security and real-device journeys remain deferred, separate release-validation gaps. See [remaining coverage](remaining-coverage.md).

Validate every implemented feature in the current checkout, one feature at a time. Combine deterministic unit tests, repository/database integration tests, Cubit tests, a focused set of real application journeys, and exploratory sessions. Use existing Flutter, bloc_test, mocktail, in-memory Drift, and Patrol infrastructure before adding tools. A database test does not prove that a screen works, and a screen displaying a saved value does not prove it reached the server.

Every supported create/update/delete action uses the [persistence protocol](validation-protocol.md). Features with deactivation, invitation revocation, append-only history, or settings updates use their actual lifecycle; do not invent delete actions. Run permissions against ordinary authenticated users as well as the existing privileged users. Test internal and provider modes separately.

The initial planning investigation was read-only. Execution evidence below and in test headers supersedes the planning snapshot; no application/database fixes are authorized. The existing `docs/plans/contact-support/` folder is unrelated and unchanged.

## Dependencies and decisions before execution

1. Explicit approval in a subsequent user message. This document does not authorize implementation or testing by itself.
2. Confirm the target project, company IDs, test environment, and supported release platforms. Development/staging entrypoints do not establish database isolation. Prefer a disposable staging database and controlled R2/mail/push resources.
3. Provision the five ordinary identities in [accounts-and-environment.md](accounts-and-environment.md). The user reports that both existing `.env` users are super admins; treat their denial coverage as invalid until independently verified. Do not demote either account.
4. Reconcile current schema, permissions, functions, triggers, and deployment versions before dependent database assertions. If an authenticated inspection is unavailable, explicitly give the user a read-only Supabase SQL checkpoint and wait for all results. SQL-editor success is not evidence of end-user RLS enforcement.
5. Address the live-runner/report/recovery issues in [repository-findings.md](repository-findings.md) before live mutation suites. Missing accounts, incomplete cleanup, or skipped security tests block the corresponding validation gate.
6. Invitations, password emails, and push delivery require explicit authorization to send to named test recipients/devices. Production deletion, including cleanup, requires explicit confirmation under the database rules. Prefer running the full mutation catalogue in staging.

## Execution updates from the user

- 2026-09-19: cross-layer CRUD, persistence, domain, and state test work is authorized. The later scope revision excludes new widget tests. Keep live/security/recovery execution deferred in the current scope. Small meaningful test and plan commits are authorized; temporary validation headers stay uncommitted.

- Implement the tests, run exactly one test file at a time, and finish recording its result before starting the next file.
- Add a dated validation status at the beginning of each executed test file. A failed/blocked execution is not marked passed, and a header never disables future regression runs.
- Record errors for future fixes in [the persistent findings list](../../testing/validation_findings.md); do not fix application/database defects during this task.
- Delete a feature step Markdown only when its planned coverage has been implemented and executed with evidence and recorded findings. Replace its index link with test/evidence links. Partial coverage, blocked execution, and default-skipped live suites are not complete feature coverage.

## Execution and layer boundaries

Each step contains numbered phases. Execute one implementation layer per turn, in data → domain → Cubits/state → UI order. Tests, evidence, and plan progress for that layer travel together. Infrastructure/readiness/release phases state their own scope. A request to execute the whole plan does not silently waive the user's layer restriction; crossing layers needs explicit permission.

Completing one feature before moving to the next is the default. Minimal related records can be provisioned through the fixture-builder contracts verified in Step 02; that does not claim the later feature itself passed. Cases requiring later application behavior remain blocked until the named dependency is validated, then return to the affected phase. Final cross-feature journeys are in Step 24. A defect in another production layer is recorded and proposed for a separate approved fix, not patched opportunistically during test work.

After each phase, record command/check, result, date, build/commit, case IDs, and evidence in that step and the run record. Mark `Complete` only after acceptance and required checks pass. Mark the index step only when every phase passes. Reopen affected phases after behavior changes. A failed, blocked, skipped, or unrun required case never counts as passed.

## Ordered checklist

- [ ] [01 — Environment, accounts, and test oracles](step-01-readiness.md)
- [ ] [02 — Test harness, reporting, and recovery](step-02-test-harness.md)
- [ ] [03 — Authentication, sessions, and navigation](step-03-authentication.md)
- [ ] [04 — Company selection and company settings](step-04-company.md)
- [ ] [05 — Users, invitations, and permissions](step-05-users-permissions.md)
- [ ] [06 — Locations](step-06-locations.md)
- [ ] [07 — Areas](step-07-areas.md)
- [ ] [08 — Categories](step-08-categories.md)
- [ ] [09 — Sectors](step-09-sectors.md)
- [ ] [10 — SLA policies and pause reasons](step-10-sla-policies.md)
- [ ] [11 — Assets and hierarchy](step-11-assets.md)
- [ ] [12 — Service providers and provider mode](step-12-service-providers.md)
- [ ] [13 — Checklist templates, items, and answers](step-13-checklists.md)
- [ ] [14 — Work-order CRUD, assignment, filters, and restoration](step-14-work-order-crud.md)
- [ ] [15 — Work-order pause, completion, and SLA lifecycle](step-15-work-order-lifecycle.md)
- [ ] [16 — Tasks, observations, change requests, and history](step-16-work-order-collaboration.md)
- [ ] [17 — Attachments and file recovery](step-17-attachments.md)
- [ ] [18 — Maintenance plans and generated work orders](step-18-maintenance-plans.md)
- [ ] [19 — Notifications and device tokens](step-19-notifications.md)
- [ ] [20 — Access logs and audit isolation](step-20-access-logs.md)
- [ ] [21 — Personal settings and cache management](step-21-configurations.md)
- [ ] [22 — Dashboard, navigation, and KPI accuracy](step-22-dashboard.md)
- [ ] [23 — Offline sync, realtime, and interrupted operations](step-23-sync-resilience.md)
- [ ] [24 — Cross-feature journeys and release validation](step-24-release-validation.md)

## Coverage and evidence

- [Current execution results](../../testing/application_validation_progress.md): sequential per-file counts, implemented coverage, failures and remaining gates.
- [Validation protocol](validation-protocol.md): reusable CRUD/reload, permission, fault, and automation requirements.
- [Accounts and environment](accounts-and-environment.md): concrete provisioning request and role boundaries.
- [Repository findings](repository-findings.md): verified starting point and limits of existing evidence.
- [Execution record template](execution-record-template.md): case results, defects, cleanup, and phase evidence.

Steps 03–23 map to all 19 `lib/features/` directories; areas, tasks, pause reasons, audit history, and change requests are subfeatures, not missing feature folders. Inventory/stock, work-order line items/material billing, reports, and the separate contact-support proposal are not claimed as delivered features. Reassess them if the approved release includes new implementation.

## Exit criteria

- Every applicable case has an outcome and evidence; every required phase is complete. Unsupported functionality has an explicit reason and scope decision, not a silent skip.
- No unresolved P0/P1 defect: unauthorized access, privilege escalation, lost/duplicated committed data, unusable login, or broken core work execution blocks release. P2/P3 exceptions need a named owner and explicit acceptance.
- Ordinary admin/technician/supervisor/provider and cross-company allow/deny checks pass through user-authenticated clients; the super-admin smoke results are separate.
- Persistence, dependency-safe deletion, lifecycle branches, and recovery pass on the target release build. Native-dependent cases run on real supported devices; unavailable platforms remain unvalidated.
- The critical end-to-end journey passes on two consecutive clean fixture runs. Flaky cases are investigated rather than retried until green.
- Fixtures are reconciled, profile permissions restored, pending queues accounted for, and permitted append-only test history inventoried. Preserve reproduction evidence before cleanup.
- Targeted analysis and the final selected CRUD/persistence/domain/state regression files pass. Live result counts match discovered/registered cases, and console, JSONL, and summary agree.

## Plan validation

Documentation checks passed on 2026-09-19: 29 documents, 24 linked steps, and 92 numbered phases; all local Markdown links resolve, all phases contain the required layer/actions/acceptance/validation/evidence fields, and every completion checkbox remains unchecked. A secret-value check found no copied credential/endpoint values from `.env`. Per-file `git diff --no-index --check` and repository `git diff --check` reported no whitespace errors. The feature inventory maps all 19 current feature directories to the steps above. At initial plan creation application tests had not been run. The current execution report above supersedes that snapshot; live schema and complete feature behavior remain unverified.
