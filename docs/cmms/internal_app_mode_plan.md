# ServicePro — Remaining Product Work

Reviewed on 2026-10-08. This roadmap lists only unfinished work and unresolved scope decisions.

## Open decisions

- **Recurrence selectors in the maintenance plan form**: the recurrence model and next-due-date calculation already support `dayOfMonth` and `monthOfYear`, but the authoring form does not expose selectors for them; it only preserves existing values. Decide whether v1 exposes them.

## To do

- **Asset and customer filters**: search assets and customers with filters, similar to work orders.
- **Database growth**: review stored records (logs, history, audit tables) to limit database growth.
- **Bug — profile image not updating**: picking a second image does not replace the first one. Repro: set `WhatsApp Image 2026-09-27 at 6.37.11 PM`, then `WhatsApp Image 2026-09-27 at 6.38.21 PM.jpeg` from Downloads; the image stays the same (possible cache or same storage key).
- **Dashboard improvements**: show richer work order (OS) information.
- **Auth email templates**: replace Supabase default emails (confirmation, password reset, invite, magic link) with professional pt-BR templates and branding.

## Deferred modules

- **Inventory and stock control** (after the first release): parts registry, stock movements, minimum-stock alerts, line items, and work order material consumption/costs. See [business rules](../business_rules.md#3-work-order-items--materials-future-roadmap).
- **Company default currency**: postponed.
- **Meter-based maintenance** (only on customer request): plans triggered by usage, such as machine hours, mileage, or cycle counts, instead of calendar intervals.

## Settled scope decisions

- Maintenance plans do not use Supabase Realtime; the table does not need live updates while the app is open.
