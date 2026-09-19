# Test accounts and environment

## Request to the user

Keep the two existing `.env` accounts unchanged for privileged smoke tests and approved fixture administration. Please create **five additional accounts that are not super admins**, with the following memberships. Supply credentials through local untracked test configuration, never through committed documentation or reports.

| Alias | Membership and rights | Why it is needed |
|---|---|---|
| ADMIN_A | Ordinary company administrator in test company A; not a global/super admin | Company-level administration without a global bypass |
| SUPERVISOR_A | Company A; non-admin; all-order read/update plus `managePendingRequests` and only the additional actions deliberately under test | Independent approval, escalation, and concurrent reviewer flows |
| TECH_A | Company A; non-admin; assigned-order execution and required lookups, no approval, financial management, reassignment, registry administration, or user administration | Normal worker flows and meaningful permission denial |
| PROVIDER_A | Active provider profile in a test provider company hired by A; no internal membership/administrative powers in A | Actual external contractor isolation, assigned execution, and provider creation rules |
| USER_B | Ordinary non-admin member of a separate test company B, no membership/provider link to A | Cross-company read, write, file, RPC, and realtime denial |

A sixth read-only user in A is useful for simultaneous viewer/technician tests. Initially TECH_A can use a temporary private read-only/no-permission group **serially**, with recorded restoration. Never simulate technician and supervisor concurrently with the same auth user: the existing harness reuses one account, so changing its group changes both sessions. For dual-mode testing, give SUPERVISOR_A an additional controlled provider membership after its internal baseline is validated; verify that its internal privileges never carry into provider mode. Do not use that dual-role account as the sole provider-security evidence.

## Identity verification checkpoint

Before any mutation suite, authenticate each identity independently and record sanitized user ID, actual company membership, provider links, `is_admin`, effective permissions/scopes, and the result of the deployed super-admin check where callable. Confirm fresh-token behavior and active-company handling. A role label, email variable name, or permission group name is insufficient proof. An ordinary company admin may legitimately have broad company rights but must not become a global admin.

Both existing users are super admins according to the user. Local Dart code and a local SQL migration disagree about one privileged-email list; deployed status is unknown. This is a preflight question, not authorization to change anyone's privileges. Denial tests require `is_super_admin = false` and, except ADMIN_A, `is_admin = false`.

The current harness only loads `INTEGRATION_TEST_ADMIN_*`, `INTEGRATION_TEST_TECH_*`, and optional `INTEGRATION_TEST_FOREIGN_*`. Supervisor/provider currently reuse TECH credentials. Extend test-only configuration after approval to keep privileged identities separate and support distinct ordinary accounts; new aliases/key names are proposed, not supported today. Require an explicit company B ID rather than accepting the current fallback to company A for a foreign session.

## Environment and data checkpoint

Record the confirmed project reference, build commit, flavor/entrypoint, endpoint, schema/function versions, OS/browser/device, timezone, and account aliases. Do not store passwords, tokens, keys, full credential URLs, or real user data in evidence. `.env` currently has integration credentials and is also declared as a Flutter asset: verify release packaging excludes test passwords before distributing any build. This is a source-level exposure risk; no built artifact was inspected in planning.

Use isolated companies A and B in staging with controlled files and recipients. Existing-data reuse is currently enabled in `.env`; disable it for mutation fixtures in a later approved configuration change. Create data with a unique run ID and deterministic case suffix, e.g. `[IT] <run-id> LOC-01`. Track exact table/row/object IDs and ownership. A prefix alone does not authorize modifying or sweeping another run's records.

Seed dependencies in order: companies/memberships → permission groups → categories/sectors/SLA/pause reasons → locations → areas → assets/provider relationships/checklists → work orders and children → maintenance-generation fixtures. Reverse dependency order for cleanup, respecting deployed soft-delete/deactivation/append-only rules. A feature can provision minimal dependencies via already-validated data paths without claiming those features' UI has passed.

Do not mutate existing business records. Use disposable test device tokens and test mailboxes; identify recipients before any invite/reset/resend/push run. Production must not be treated as a disposable environment. If staging is unavailable, propose a bounded production subset with exact records and deletion scope, leaving destructive, concurrency, and load scenarios blocked until approved.

## User-run Supabase checkpoints

If tooling cannot inspect the approved project as intended, provide read-only SQL for the relevant tables, grants, policies, function definitions, triggers, constraints, realtime publication, and maintenance scheduler. Ask for every result set and wait before dependent assertions or migration proposals. Privileged metadata inspection is administrative evidence only; actual permission behavior must be tested with the accounts above and a public client key plus their access tokens. Never use a service-role client as the actor in end-user authorization tests.

No accounts were created or authenticated, and no environment values were changed during planning.
