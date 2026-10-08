# ServicePro — Remaining Product Work

Reviewed on 2026-10-08. This roadmap lists only unfinished work and unresolved scope decisions.

## Open decisions

- **Recurrence selectors in the maintenance plan form**: the recurrence model and next-due-date calculation already support `dayOfMonth` and `monthOfYear`, but the authoring form does not expose selectors for them; it only preserves existing values. Decide whether v1 exposes them.

## Deferred modules

- **Inventory and stock control** (after the first release): parts registry, stock movements, minimum-stock alerts, line items, and work order material consumption/costs. See [business rules](../business_rules.md#3-work-order-items--materials-future-roadmap).
- **Company default currency**: postponed.
- **Meter-based maintenance** (only on customer request): plans triggered by usage, such as machine hours, mileage, or cycle counts, instead of calendar intervals.

## Settled scope decisions

- Maintenance plans do not use Supabase Realtime; the table does not need live updates while the app is open.
