# Step 01 — Contact configuration and platform adapter

## Phase 1 — Configure destinations and wrap platform operations

- [ ] Complete
- Layer: data/infrastructure only, with its tests and documentation.
- Actions/files: extend `lib/config/app_config.dart` and its test configuration with support email, optional WhatsApp number and optional service hours. Introduce a small shared platform service contract/implementation under `lib/core/services/` wrapping external URI launch and clipboard operations. Reuse an existing suitable abstraction if inspection finds one. Register through the existing DI pattern. No new database or feature repository is needed for external contact launching.
- Keep this adapter independent of future feature-domain types so this phase compiles before Step 02. Accept a URI/text and return an explicit operation outcome; do not construct support messages or claim delivery. Business validation belongs to Step 02. Keep package-specific imports in the adapter.
- Destination values come from flavor configuration. Missing optional settings must not crash startup; missing production email must be visible in release validation. Maintain safe defaults for existing `TestAppConfig` callers. Do not commit personal numbers or invent operational contact values.
- Attempt supported external launches and handle false/exception outcomes. Use external platform/browser handling, avoid mandatory installation probes, and evaluate platform settings only if needed by the actual adapter. Retain a web-compatible user-gesture launch path.
- Acceptance criteria: tests cover missing configuration, successful launch, false/exception failures, successful/failed copy, and flavor separation without opening real applications. Existing configuration callers remain compatible.
- Validation: format changed Dart files; `flutter analyze lib/config lib/core/services testing/mocks`; run focused configuration/service tests and affected existing tests. Use mocks following `.agents/rules/quality_assurance.md`. Record exact test paths, command results and date during implementation. If generated DI output is unavailable, leave the phase unchecked and report that blocker.
- Validation evidence: not run; implementation not approved.
