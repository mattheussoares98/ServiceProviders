# Contact support and current backlog review

Reviewed: 2026-09-19. Status: proposed; implementation requires explicit approval in a subsequent message.

## Objective and scope

Add a discoverable way to contact ServicePro product support, and record what remains in the existing product plans. This means application support, not contacting a work order's assigned service provider.

The read-only findings are in [the backlog review](backlog_review.md). That review compares the current checkout with the company-mode roadmap, generator plan, and currency plan. It does not certify the whole application or live database.

## Recommended first release

- Add a shared `Contato com o suporte` page, reachable from the internal and provider drawers and the login screen, including when logged out or offline.
- Make email the primary channel. Offer WhatsApp when a monitored business number is configured. Email is the proposed default because staffing and response expectations are not known yet.
- Let users describe the problem, preview/edit the message, and choose a channel. Open an external draft; the user sends it there. Never label a successful launch as a sent message or created ticket.
- Always show copyable contact details and message text. Handle missing apps, blocked launches, unavailable clipboard, missing configuration, and offline use without losing the draft. No queued support submissions.
- Use central flavor configuration for the support email, optional WhatsApp number, and optional published service hours. Do not use a provider company's contact fields or invent real contact details.
- Limit prefilled content to the app name, platform, and user-entered description. Optional company/work-order context requires explicit selection and preview; omit it from the initial release unless needed. No automatic logs, access tokens, attachments, or account data.

## Channel tradeoffs

| Option | Benefit | Cost or limitation | Proposed scope |
|---|---|---|---|
| Email draft | Simple asynchronous support; user can add attachments in their email app | Needs an email handler; launch does not confirm delivery | Primary, with copy fallback |
| WhatsApp click to chat | Convenient for users who already use WhatsApp | Needs a real monitored account; creates expectations of chat availability | Optional secondary channel |
| In-app tickets | Status/history and team assignment inside the product | Requires backend, authorization, operations, notifications and retention decisions | Defer until support volume justifies it |

Technical references checked on 2026-09-19: [Flutter url_launcher](https://pub.dev/packages/url_launcher) documents email handling and launch failures; [WhatsApp click to chat](https://faq.whatsapp.com/5913398998672934) describes links and prefilled messages. The app already declares `url_launcher: ^6.3.2`; verify the resolved version before implementation. No WhatsApp messaging API, email delivery service, or database change is needed for this proposal.

## Dependencies and decisions

- Before production release: provide the monitored support email, decide whether WhatsApp is staffed, and supply its international number if enabled. Agree on hours before displaying them; do not promise response times without an operational commitment.
- Approve the proposed public login entry and availability to both app modes. Product support should not require company administration permissions or a selected company.
- Missing production contacts block release, but adapter and UI work can be tested with fixtures. Keep development/staging contacts explicit to avoid accidentally opening production support during tests.
- Follow existing `AppConfig`, shared service, Cubit, routing, and widget conventions. Inspect their APIs again at implementation time. Generated DI/routes must come from the existing watcher; never run `build_runner` or edit generated output manually.
- Implement one layer per turn in the order below. Tests and supporting documentation belong to that layer. Approval of this plan alone does not waive the one-layer-per-turn rule.

## Ordered implementation checklist

1. [ ] [Step 01 — Contact configuration and platform adapter](step-01-contact-configuration.md)
2. [ ] [Step 02 — Support message and channel use cases](step-02-support-use-cases.md)
3. [ ] [Step 03 — Support state and navigation](step-03-support-state.md)
4. [ ] [Step 04 — Support page and entry points](step-04-support-ui.md)

Every phase starts unchecked. After implementation and successful validation, record the command/check, result, and date beside its completion checkbox. Failed, blocked, or unrun checks leave the phase unchecked. Complete an index step only when every phase is validated; reopen it if later changes invalidate that evidence.

## Planning validation

2026-09-19: inspected roadmap/plan files, maintenance implementation and test sources, company parameters, navigation, and current contact-launch usage. Python checks of all six new Markdown files passed for local links, required phase fields, unchecked phase status, and whitespace; per-file `git diff --no-index --check /dev/null <file>` checks passed. The workspace-wide `git diff --check` reported a trailing blank line in the concurrently edited `docs/database_rules/maintenance_plans_rules.md`; that unrelated file was preserved. No Flutter tests, build, dependency resolution, live database query, or migration ran during this planning task.
