# Current backlog review

Date: 2026-09-19. Evidence scope: this checkout, read-only source inspection. Existing test files demonstrate coverage intent, not passing execution in this review. Live Supabase schema, deployed functions, cron jobs and migration status remain unverified.

## Plans reviewed

- [Company-mode roadmap](../../cmms/internal_app_mode_plan.md)
- [Maintenance generator plan](../phase_6_generator.md)
- [Company currency plan](../company_currency_configuration.md)

## Confirmed remaining work

| Item | Current evidence | Remaining implementation |
|---|---|---|
| Automated maintenance work orders | `supabase/migrations/20260919163000_create_maintenance_plan_generator_function.sql` defines generation and an hourly cron schedule. Application and functional testing remain unverified. | Review the draft, reconcile/apply against the live schema, and validate authorization, idempotency/concurrent execution, atomic advancement, per-plan errors and scheduling. Source presence does not establish deployment or correctness. |
| Company default currency | The currency plan is unchecked; `lib/core/clients/local/drift/tables/company_parameters_table.dart` has no currency column. Maintenance `plan_form.dart` defaults to `BRL`; `work_orders_cubit.dart` also defaults to `BRL`. | Finish remote/local configuration, entity/model mapping, company settings, and inherited creation defaults. Preserve currency on existing records; review work-order display, which currently uses `toBRL()` in `work_order_details/info_items.dart`. |
| Contact support | No support feature/route/drawer entry was found. `lib/core/data/states/failure_state.dart` and `lib/shared_ui/utils/client_mixin.dart` already tell users to contact support without providing a destination. `lib/config/app_config.dart` has no support contacts. | Implement the [four support steps](implementation_plan.md#ordered-implementation-checklist). |
| Inventory and work-order materials | Inventory remains deferred in the roadmap; no inventory/stock feature directory was found. `docs/business_rules.md` section 3 explicitly treats line items/materials as future work. | Separately scope stock/parts, movements, minimum-stock alerts, consumption and cost integration. This support plan does not authorize or fully specify inventory. |
| Meter-based maintenance | The roadmap promises meter-based recurrence, but `IntervalUnit` contains only days/weeks/months/years and the form uses those units. | Decide whether meter readings/triggers belong to a later release; they are not implemented by the current calendar recurrence. |

## Scope decisions still needed for maintenance

- Offline reads: `maintenance_plans_repository_impl.dart` has no local fallback; its tests explicitly expect offline failure. Local table/data-source existence does not mean offline support is wired. Treat this as a policy decision, not an accidental defect without further evidence.
- Realtime: `watchPlansRealtime` is implemented in the remote source but has no caller in `lib` or `test`; the Cubit reloads after its own actions. Decide whether automatic refresh for other users and generator activity is required.
- Calendar anchors: `dayOfWeek`, `dayOfMonth`, and `monthOfYear` exist in recurrence logic, but the form only preserves existing values and exposes interval/unit, lead time, and duration controls. Decide whether users need explicit weekday/month-day/month selectors.
- Generator semantics: settle overdue catch-up behavior, timezone policy, disabled/deleted plans, invalid/deleted targets, required work-order defaults, and bounded batches before finalizing and deploying the generator.
- Generator authorization: the current migration declares `public.generate_due_maintenance_work_orders()` as `SECURITY DEFINER`, grants execution to `authenticated`, and scans due plans across companies without a caller authorization check. Review/restrict invocation to the intended worker before deployment; a normal authenticated caller must not gain a cross-company generation capability. This is a source-level concern, not a claim about current live grants.

## Suggested sequence

1. Review, deploy and validate the maintenance generator to complete the automated-maintenance workflow already exposed in the UI. First resolve its invocation permissions and reconcile the live database with repository SQL. If agent access is unavailable, explicitly request user-run read-only SQL and wait for all results before dependent schema work; do not assume the September 18 inspection is still current.
2. Deliver contact support as an independent small feature once approved and real contact ownership is established.
3. Complete company currency settings before advertising multiple currencies, including consistent display.
4. Plan inventory/materials and meter-based maintenance separately when their scope is chosen.

These priorities are recommendations, not approval to implement. This was a review of the tracked product plans and related code, not an exhaustive security, behavior, or release-readiness audit.
