# ServicePro CMMS — Documentation Index

A **Computerized Maintenance Management System (CMMS)** for Brazilian enterprises managing recurring maintenance across facilities (hospitals, academies, factories, hotels, commercial buildings).

> [!IMPORTANT]
> **Scope for V1**: Offline-capable local database + core UI + file management + Supabase backend + sync engine + personal configuration. **Additions to V1**: Firebase FCM push notifications for work order assignment, Company parameters admin panel (offline alerts/email notification toggles), and Work orders list with search filters and cursor-based pagination. Excluded from V1: QR code scanning, real-time WebSockets (planned for V2), background sync, and multi-company support.

> [!NOTE]
> All core V1 & V2 foundation capabilities (SyncEngine outbound FIFO sync, device token FCM notifications, Provider Mode, SLA policies, escalations, real-time sync, and access logs) are implemented. See the roadmap documents below for details.

> [!IMPORTANT]
> **Implementation Methodology**: We build step-by-step: table-by-table, column-by-column, data-source-by-data-source, repository-by-repository, module-by-module, page-by-page. Each component must be verified and aligned before proceeding.

## Documentation Map

| Document | Purpose |
|---|---|
| [Architecture](/docs/cmms/architecture.md) | Data flow, sync design, file management, invitation flow, infrastructure |
| [Sync Engine](/docs/cmms/sync_engine.md) | Outbound FIFO sync engine architecture, error telemetry, conflict handling |
| [Roadmap & Feature Status](/docs/cmms/internal_app_mode_plan.md) | Current implementation status and prioritized feature roadmap |

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
