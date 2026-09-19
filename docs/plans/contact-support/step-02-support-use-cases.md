# Step 02 — Support message and channel use cases

## Phase 1 — Define message and channel behavior

- [ ] Complete
- Layer: domain only, with its tests and documentation. Depends on Step 01.
- Actions/files: add support entities and focused use cases under `lib/features/support/domain/` for available channels, message preparation, launching a selected channel, and copying contact/message text. Use the shared service contract prepared in Step 01, consistent with the project's shared-infrastructure exception; never import a feature data implementation into domain.
- Represent channel/outcome values as untranslated codes. Build a bounded message from app name, platform and user description, retaining Unicode, spaces, line breaks, ampersands and plus signs. Put Portuguese labels/templates in presentation and pass their text into domain preparation where necessary.
- Validate configured email and normalize the configured WhatsApp number to international digits. Construct email and WhatsApp destinations from known schemes/hosts and configuration, never from arbitrary user-supplied destinations. Specify and test a concrete description limit before coding; show that limit in the future UI rather than silently truncating.
- Use a correctly encoded `mailto` subject/body and an HTTPS WhatsApp click-to-chat link with encoded text. Keep the WhatsApp base URI in central configuration. Invalid or missing configuration excludes that channel with a reason available to presentation.
- Distinguish launch/copy success from actual message delivery. Support requires no authentication, company permission or network request to prepare/copy a draft. Do not query tenant records or send diagnostics automatically.
- Acceptance criteria: deterministic tests cover both channels, malformed/missing contacts, optional WhatsApp, special characters, empty/oversized descriptions, and propagated platform failures. No messages are sent during tests.
- Validation: format changed files; `flutter analyze lib/features/support/domain testing/mocks`; `flutter test test/features/support/domain/use_cases/use_cases_test.dart`, plus affected existing domain tests. Keep reusable fixtures/mocks under `testing/mocks/`.
- Validation evidence: not run; implementation not approved.
