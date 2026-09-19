# Step 01 — Environment, accounts, and test oracles

Dependencies: subsequent approval of this plan. Scope: readiness and read-only inspection; no fixture writes in this step.

## Phase 1 — Environment and identity inventory

- [ ] Complete
- **Layer:** Data inspection and test configuration review.
- **Actions/files:** Follow [accounts-and-environment.md](accounts-and-environment.md). Inspect `.env` key usage without exposing values, `lib/config/`, app entrypoints, session/permission code, and live schema metadata for the approved environment. Authenticate only the designated test accounts after execution approval. Record actual memberships, admin/super-admin status, selected company, provider links, and available platforms. Identify mail/push/file destinations and scheduler side effects before enabling tests.
- **Acceptance criteria:** Isolated project/companies and five ordinary account roles are verified; no claimed least-privilege identity has a super-admin bypass. Missing accounts or uncertain project ownership block mutation tests. User confirms release platforms and allowed external recipients before delivery tests.
- **Validation:** Sanitized identity/metadata report; compare actual roles with the account matrix. If live inspection is unavailable, provide a read-only user-run SQL checkpoint and wait for every result. No migration or test-data creation here.
- **Evidence:** Partial read-only verification on 2026-09-19: all five configured test accounts authenticated in a direct probe and reported no super-admin bypass; A/B memberships and provider linkage were checked. Guarded Dart readiness then failed 13/13 cases because credential parsing changes password bytes (VAL-001). Supervisor grant names differ from the app matrix (VAL-002). See [execution evidence](../../testing/application_validation_progress.md) and [findings](../../testing/validation_findings.md). Environment/delivery/platform gates remain open; no business-row mutations.

## Phase 2 — Freeze expected behavior and scope

- [ ] Complete
- **Layer:** Validation specification (documentation only).
- **Actions/files:** Reconcile `docs/business_rules.md`, per-table schema/rules, existing tests, and live definitions. Build the resource/action/role matrix and confirm ordinary-admin versus global-admin rules. Define offline support per feature, duplicate/manual-generation semantics, delete dependency boundaries, and concurrent-edit conflict expectations. Agree on release platforms and measurable performance limits. Add unresolved decisions to a run record rather than guessing an expected result.
- **Acceptance criteria:** Each critical scenario has an independent expected result and test actor; material ambiguities have an owner and block only dependent cases. Inventory/line items/support proposals remain outside delivered-feature claims unless release scope changes.
- **Validation:** Review mapping from all 19 feature folders and routed surfaces to Steps 03–23; verify every known dependency and external service has a test or a declared blocker.
- **Evidence:** Not run. Record check, result, date, and report link during execution.
