# Step 03 — Support state and navigation

## Phase 1 — Manage channel actions and recoverable failures

- [ ] Complete
- Layer: cubits/state only, with its tests and documentation. Depends on Steps 01–02.
- Actions/files: add `SupportCubit`, `SupportCubitUseCases` and state under `lib/features/support/presentation/cubits/support/`. Use `BaseCubit`, section states, equality and `withSection`; inject use cases through the aggregator.
- Load available contact channels/hours without requiring auth/company state. Retain the user's editable description and prepared message through failed launches; avoid any persistence of support drafts beyond the current flow in this release.
- Track launch and copy operations independently; prevent duplicate activation, recover from failure, and guard completion after disposal. A launch success means only the external app/browser was opened. Expose fallback state so UI can show/copy the contact address and draft.
- Account for web user-gesture requirements: prepare the URI before channel activation and initiate launch without unrelated asynchronous lookups ahead of it. Include this in later browser acceptance checks.
- Keep navigation through existing Cubit/ClientMixin conventions. Defer concrete support route references and entry-point wiring until the route/page exists in Step 04, avoiding a generated-route dependency in this phase.
- Acceptance criteria: `bloc_test` covers initial/channel availability, logged-out use, running/success/error sections, retained draft, independent copy outcomes, repeated taps and disposal. No “sent” state is emitted from URI launch success.
- Validation: format changed files; `flutter analyze lib/features/support/presentation/cubits testing/mocks`; `flutter test test/features/support/presentation/cubits/support_cubit_test.dart` and affected existing state tests.
- Validation evidence: not run; implementation not approved.
