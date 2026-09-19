# Repository findings and planning evidence

Snapshot: 2026-09-19. Source inspection only; these are not current runtime results.

| Verified local evidence | Consequence for validation |
|---|---|
| 19 directories in `lib/features/`, all with feature tests; 203 `*_test.dart` files under `test/`, including 9 live integration suites | Reuse coverage, inspect assertions, and measure gaps by behavior. File count is not test-case count or proof of correctness. No tests were run during planning. |
| `lib/routing/routes.dart` and `lib/features/home/presentation/pages/home_page/widgets/home_drawer.dart` expose company/users, registries, providers, checklists, maintenance, work orders, and access logs | Feature checklist is grounded in routes and navigation, including nested provider routes. |
| `pubspec.yaml` has Flutter integration_test, Patrol, bloc_test, mocktail; root `integration_test/` is absent | Existing database tests do not provide a full real-app UI journey suite. Build that suite incrementally after approval. |
| Platform folders: Android, iOS, web, macOS, Windows; development/staging/main entrypoints exist | Directory existence does not prove a supported/releasable platform. Confirm the release matrix and run device-dependent checks there. |
| `.env` contains admin/tech credential keys; existing-data reuse and auto-cleanup are enabled; no optional foreign-account keys found | Do not run mutation suites as-is. Keep credential values out of evidence and require isolated fixtures and additional identities. |
| `pubspec.yaml` bundles `.env` as an asset | Verify distribution excludes test passwords. This is a packaging risk identified from source, not a verified leaked release artifact. |
| `user_profile_entity.dart` has a Dart privileged-email list; `20260906183000_fix_super_admin_email_list.sql` removes one email from the SQL list | Frontend/backend super-admin classification may differ; user says both configured users are privileged. Deployment and actual rights must be checked rather than inferred from the migration. |
| `integration_session.dart` reuses TECH credentials for technician, supervisor, and provider; foreign company can fall back to company A | Independent role handoffs and foreign-tenant assertions need distinct verified sessions and explicit company IDs. |
| `integration_permission_fixture.dart` blocks repointing `is_admin` users but does not inspect super-admin status; it mutates a profile's permission group | Ordinary-denial results can be invalid with a privileged technician. Fixture setup must use an authorized setup actor without granting the test actor administrative setup rights. |
| `tool/run_integration_tests.sh` captures Flutter status but ends `exit 0`; report generation failure is tolerated | Automation must propagate failure and detect incomplete/empty reports. Do not use script exit alone as a test gate. |
| The script removes `build/integration_report/`; permission fixture recovery ledger is inside that directory | A subsequent invocation can erase interrupted-run recovery evidence before recovery runs. Preserve ledgers outside disposable report output before live runs. |
| Recovery catches errors then deletes its ledger; cleanup clears tracked IDs even when cleanup errors remain | Add interruption/retry tests and durable unresolved IDs; verify restoration by fresh reads. Do not claim cleanup solely from attempted operations or counter totals. |
| `location_integration_test.dart` uses admin data sources; deletion is inside `if (autoCleanup)` | Make delete behavior an explicit case independent of cleanup preference. Add UI, ordinary-role, and fresh-session persistence checks. |
| `work_order_lifecycle_integration_test.dart` uses admin throughout and manually applies some status updates | It cannot prove technician/provider restrictions or app orchestration/trigger-only transitions. Add independent actors and verify status before any corrective write. |
| `checkedTest` emits JSONL; several registry suites use plain `test()` | Generated summaries must reconcile the complete runner case inventory, including plain tests, setup failures, and absent/skipped identities. |
| `INTEGRATION_TEST_ERRORS.md` is dated 2026-09-06 and lists 13 passing cases in two work-order areas | Historical evidence only, not a full-suite or current security sign-off. Its cleanup/schema statements need live reconciliation. |
| `locations_repository_impl.dart` supports local mutation fallback; `SyncEntityType` covers orders/tasks/observations/pauses/files/logs/checklist answers/change requests, not locations | Suspected persistence gap to reproduce: local success may not reach the server. Audit every registry fallback; do not conclude a bug solely from enum inspection. |
| Provider work-order and lookup repository paths deliberately omit local fallback/cache writes | Validate online-only behavior, mode switches, and no tenant data contamination. |
| Maintenance Plans now has remote CRUD/generation, a remote-only repository, recurrence use case, Cubit/pages, enabled navigation, permissions, schema/rule docs | Include it fully. Earlier local-only-scaffold notes are outdated for this checkout. Deployed RPC/scheduler correctness remains unknown. |

## Sources to use during execution

- `.agents/rules/quality_assurance.md`, `.agents/rules/database.md`, and the task-relevant specialist rules.
- `docs/business_rules.md` for pause/completion, resume, closed-order restrictions, and future line items.
- `docs/schema/index.md` plus feature table files; `docs/database_rules/global_rules.md` plus table-specific guards/policies; reconcile these with live definitions.
- `lib/features/users/domain/use_cases/has_permission_use_case.dart`, `domain/entities/permission/provider_mode_permission.dart`, and scope enums for client permission contracts.
- `test/integration/core/`, `test/integration/tests/`, `tool/`, existing feature tests, and `testing/mocks/` for reusable infrastructure.
- `supabase/functions/` for invite-user, invite-service-provider, generate_presigned_url, cleanup-attachments, and send-push-notification caller/tenant checks.

No live defect is claimed as reproduced by this investigation. The runner exit/recovery behavior is directly visible in source; product risks require the planned execution evidence.
