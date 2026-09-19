# Step 24 — Cross-feature journeys and release validation

Dependencies: Steps 01–23 applicable to the agreed release, including required platform and account coverage. Scope: validation only; findings do not authorize unrelated fixes, deployment, or account changes.

## Phase 1 — Verify backend contracts and recovery readiness

- [ ] Complete
- **Layer:** Data validation.
- **Actions/files:** Reconcile the final permission/action matrix, fixture ledger, API/RLS/RPC/Edge Function results, scheduler checks, queue recovery and file authorization evidence. Re-run affected data/security cases against the release backend after any schema change; verify that all required ordinary-role/company B cases actually ran. Review deployment/version differences and fixture retention in this plan's run records.
- **Acceptance criteria:** No critical data-loss, duplication, tenant leak or privilege escalation remains; all required data cases pass. No unresolved permission restoration or unknown fixture ownership. Metadata inspection and privileged smoke checks are not counted as user-security tests.
- **Validation:** Reviewed guarded live suites run serially only in the authorized environment; compare runner outcomes with the complete manifest, JSONL and summary. Verify exact row/object cleanup independently and retain expected append-only records in the ledger. Security checks needing missing accounts remain blocked.
- **Evidence:** Not run. Record command/check, result, date and run link.

## Phase 2 — Complete real user journeys and exploratory testing

- [ ] Complete
- **Layer:** UI/end-to-end validation; no production edits.
- **Actions/files:** Execute the journeys below on a production-equivalent build in the approved test environment using the real-app harness/manual runbook. Record the exact entrypoint, backend, command, platform and actor handoffs. Add minimal regression journeys only where this finds a coverage gap. Inventory every routed screen/action and compare it with the tested matrix.
- **Acceptance criteria:** All applicable journeys pass on two clean fixture runs; required platform variants pass. Exploratory findings are triaged, critical defects resolved and regression-tested, and lower-severity exceptions explicitly accepted. Missing hardware/services are disclosed as unvalidated coverage.
- **Validation:** Record UI actions, screenshots/video, independent authenticated reads, queue/file outcomes, cross-session observations and cleanup. Use bounded waits with explicit failure timeouts rather than arbitrary delays; don't rerun a flaky result until it appears green.
- **Evidence:** Not run. Record command/check, result, date and run link.

### Journey A — A normal internal workday

1. ADMIN_A signs in; selects company A; creates a category, sector, SLA policy, location, area and asset. Restart and verify each independently.
2. Create checklist with required items, create an order referencing these records, assign TECH_A. TECH_A refreshes in a second app/device and sees only permitted work.
3. TECH_A starts, adds a task and observation, fills checklist, uploads evidence, pauses, restarts, resumes and requests completion.
4. SUPERVISOR_A reviews pause responsibility, rejects the first completion request with a reason, then approves a valid resubmission. Both users reload; status, timestamps, history, files, notifications and KPI totals agree.
5. Attempt parent deletions while active dependencies exist; verify rejection. After closing/removing run-owned dependents as permitted, remove eligible records and verify absence after fresh login. Retain required history.

### Journey B — External provider work

1. Authorized administrator provisions/invites the test provider only after recipient authorization. PROVIDER_A accepts and accesses the permitted client.
2. Assign an order and execute provider start → pause → resume → completion request. The internal supervisor approves; the provider cannot self-approve, reassign or alter restricted finances.
3. Enable/disable provider creation through company parameters and test both results. Wrong company/asset/order IDs are denied.
4. Repeat with a dual-mode internal administrator acting as provider, then revoke membership while logged in. Confirm online-only behavior and no internal-cache contamination.

### Journey C — Preventive maintenance

1. Create a plan with known recurrence/checklist/assignment and reload from a second session.
2. Generate an order manually, then run an isolated due-scheduler occurrence and approved overlap/retry cases. Check exact occurrence count, next due date, copied fields and plan links.
3. Complete the generated order using the normal workflow. Deactivate the plan, verify no further scheduled generation, then test eligible deletion and retained history.

### Journey D — A technician loses connectivity

1. Load assigned work online, disconnect, then perform each supported queued action. Observe pending state and terminate/restart the app.
2. Reconnect with a response-loss fault during replay. Verify exactly one committed result per intended action and correct dependency ordering.
3. Repeat with permission revoked, parent removed and company/user switched. Pending data is preserved/rejected according to the approved policy and never replayed as the wrong user.
4. Attempt a registry edit with local fallback, provider mutation and maintenance generation offline; verify each feature's declared guarantee and expose any silent persistence loss.

### Journey E — Isolation and hostile navigation

1. USER_B and signed-out clients try fixture IDs through routes, direct API, RPC/Edge Functions, attachment URLs and realtime subscriptions.
2. TECH_A tries restricted profile/group/financial/approval actions and known unassigned orders. Snapshot rows before/after to prove denied writes had no effect.
3. Change permissions while a form is open, switch company while a request is delayed, and sign out while events arrive. Check both UI and remote state for stale-data leakage.

### Exploratory charters

- Impatient user: double clicks, repeated back/forward, cancellation, form left open overnight, stale selector, delete while another user edits.
- Field technician: poor signal, intermittent connection, limited storage, denied camera, long upload, timezone/date boundary and expired session.
- Administrator: large paginated lists, similarly named records, permission changes, changed company defaults, bulk event bursts and lost email links.
- Accessibility/platform: keyboard traversal, screen reader labels, large font, contrast, responsive widths, pt-BR accents/date/currency, Android/iOS native files and notifications, supported browser engines. Desktop builds are required only if confirmed release targets.

## Phase 3 — Regression and release report

- [ ] Complete
- **Layer:** Validation/reporting; no implementation changes.
- **Actions/files:** Consolidate run evidence, feature/case counts, defects, platform/role coverage, performance measurements and cleanup outcomes under this plan. Recheck the final build contains no test credentials. Document owners and explicit acceptance for P2/P3 exceptions; propose any unfinished work separately.
- **Acceptance criteria:** Index checkboxes accurately match phase evidence, no required blocked/skipped case is counted as passed, critical flows are stable, and the release decision states remaining limitations. No automatic deployment is authorized by passing this plan.
- **Validation:** After all relevant fixes, `flutter analyze` and `env -u INTEGRATION_TESTS flutter test`; review critical branch coverage and case manifest, not just totals. Re-run only affected live/UI checks unless changes invalidate broader evidence. Compare agreed performance limits with repeatable staging measurements. Review plan links/diff and sanitized evidence.
- **Evidence:** Not run. Record command/check, result, date and final report link.
