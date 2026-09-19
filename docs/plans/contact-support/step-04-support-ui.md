# Step 04 — Support page and entry points

## Phase 1 — Present the support flow

- [ ] Complete
- Layer: UI, including presentation navigation wiring, tests and documentation. Depends on Steps 01–03.
- Actions/files: create `lib/features/support/presentation/pages/support/support_page.dart` and page-local widgets. Register its public route in `lib/routing/routes.dart` and constants in `lib/routing/helper/route_data.dart`; consume watcher-generated output only. Add Cubit-mediated entry points in the internal/provider home drawers and login page after inspecting their current APIs.
- Use `BaseScaffold`, existing shared inputs/buttons/text, responsive spacing, and pt-BR `.hardcoded` strings. Keep the page file under 100 lines through extraction. Add `Contato com o suporte`, description/preview, email action, conditional WhatsApp action, published hours when configured, and copy/selectable contact/message text.
- Make the route available before login and in both app modes without a company/admin permission. Explain that the selected external application will open for the user to review and send. Preserve drafts on failure and allow users to choose another channel themselves.
- Cover no contacts configured, email only, both channels, loading/action error, and offline cases. Show a clear unavailable state when no real contact exists; never render a fake working support destination. Copy/selectable text remains available when external launch fails; selectable text remains usable if clipboard access fails.
- Acceptance criteria: widget tests exercise all channel combinations, draft editing, validation limits, launch failure/copy recovery, and reachable entry points in logged-out/internal/provider modes. Small-screen layouts and accessibility labels are usable.
- Validation: format changed files; targeted `flutter analyze` for support, affected home/auth/navigation paths and test helpers; `flutter test test/features/support/presentation/pages/support_page_test.dart` plus affected home/auth/navigation tests. Record exact affected test paths/results. Missing watcher-generated route output keeps this phase incomplete.
- Validation evidence: not run; implementation not approved.

## Phase 2 — Verify external handoff and document release readiness

- [ ] Complete
- Layer: UI acceptance and supporting documentation only; fixes outside UI require a separately authorized layer turn.
- Actions/files: record smoke-test evidence here and update the relevant app documentation during approved implementation. Confirm the actual support contact owner and production flavor values without publishing private credentials. Defer future tickets, automatic attachments, or message delivery services to a separate plan.
- Acceptance criteria: on supported Android/iOS devices and web, test opening email and WhatsApp drafts, preserved accents/newlines, return-to-app behavior, missing email handler, unavailable WhatsApp/account, blocked browser launch, offline behavior, and copy/selectable fallback. A successful URL open is never treated as proof WhatsApp is installed or the message was sent. Do not send real test messages without explicit authorization.
- Validation: record device/browser and check results with dates. Confirm no login is required, no support action reads another tenant's data, no draft contains automatic sensitive diagnostics, and no response-time promise was introduced. Missing platform access or contacts must remain a documented release blocker; do not check this phase complete on widget tests alone.
- Validation evidence: not run; implementation not approved.
