# ServicePro — Remaining Product Work

Reviewed against repository source on 2026-09-19. This roadmap lists only unfinished work and unresolved scope decisions. Source inspection does not confirm deployed database state or passing runtime tests.

## Active follow-ups

1. **Maintenance generator deployment and validation** — [remaining checklist](../plans/phase_6_generator.md).
   - Review invocation permissions before deployment, reconcile the live schema, and verify generation, concurrent runs, failure handling and the hourly schedule.
   - The migration is present; deployment and functional testing remain unverified.
2. **Contact support** — [implementation plan](../plans/contact-support/implementation_plan.md).
   - Email-first contact flow, optional WhatsApp, and copyable contact/message fallback.
   - Requires approved implementation and operational support destinations.
3. **Company default currency** — [implementation plan](../plans/company_currency_configuration.md).
   - Company configuration, remote/local mapping, settings UI, inherited creation defaults and consistent display.

## Deferred modules

- **Inventory and stock control**: parts registry, stock movements, minimum-stock alerts, and work-order material consumption/costs. See [business rules](../business_rules.md#3-work-order-items--materials-future-roadmap).
- **Meter-based maintenance**: reading capture, thresholds and generation rules; current recurrence units are calendar-based only.

## Maintenance scope decisions

- Decide whether offline reads are required; the current repository is remote-only.
- Decide whether to connect the existing realtime stream to the Cubit for changes from other users or the generator.
- Decide whether the authoring form should expose weekday, month-day and annual-month selectors already represented in the recurrence model.

See the [backlog review](../plans/contact-support/backlog_review.md) for source evidence and remaining risks. Current architecture, schema and business rules remain in their reference documents.
