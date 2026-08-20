# ServicePro CMMS — Documentation Index

A **Computerized Maintenance Management System (CMMS)** for Brazilian enterprises managing recurring maintenance across facilities (hospitals, academies, factories, hotels, commercial buildings).

> [!IMPORTANT]
> **Scope for V1**: Offline-capable local database + core UI + file management + Supabase backend + sync engine + personal configuration. **Additions to V1**: Firebase FCM push notifications for work order assignment, Company parameters admin panel (offline alerts/email notification toggles), and Work orders list with search filters and cursor-based pagination. Excluded from V1: QR code scanning, real-time WebSockets (planned for V2), background sync, and multi-company support.

> [!WARNING]
> **V1 scope items not yet delivered.** Two items above are documented as V1 but are not functional in the codebase today:
> - **Sync is pull-only.** Remote → local delta sync works; there is no outbound push. Offline writes stay on the device permanently.
> - **FCM cannot target a user.** Message receiving is wired, but no device token is persisted anywhere, so no notification can be addressed to a recipient.
>
> See [Internal App Mode Roadmap](/docs/cmms/internal_app_mode_plan.md) for the full gap list.

> [!IMPORTANT]
> **Implementation Methodology**: We build step-by-step: table-by-table, column-by-column, data-source-by-data-source, repository-by-repository, module-by-module, page-by-page. Each component must be verified and aligned before proceeding.

## Documentation Map

| Document | Purpose |
|---|---|
| [Architecture](/docs/cmms/architecture.md) | Data flow, sync design, file management, invitation flow, infrastructure |
| [Attachments Implementation](/docs/cmms/attachments_implementation.md) | Attachment pipeline, compression, R2 upload |
| [Resolved Questions](/docs/cmms/resolved_questions.md) | Decision log for past design choices |
| [Internal App Mode Roadmap](/docs/cmms/internal_app_mode_plan.md) | Current status of Company Mode and the ranked gap list |
| [V2 Feature Roadmap](/docs/cmms/v2_features.md) | Scope and details for V2 features |

## Related Documentation

| Document | Purpose |
|---|---|
| [App Documentation](/docs/app_documentation.md) | Technical stack overview and architectural rationale |
| [Business Rules](/docs/business_rules.md) | Pause/completion lifecycle rules and SLA impact matrix |
| [Database Schema](/docs/schema/index.md) | ERD, common columns, and per-table schema files |
| [Database Rules](/docs/database_rules/global_rules.md) | RLS policies and business rules per table |
| [Architect Rules](file:/.agents/rules/architect.md) | Folder structure, DI, routing conventions |
| [Feature Rules](file:/.agents/rules/feature.md) | Data/domain layer patterns and handlers |
| [Database Agent Rules](file:/.agents/rules/database.md) | Schema update enforcement and migration rules |
