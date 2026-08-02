# ServicePro CMMS — Documentation Index

A **Computerized Maintenance Management System (CMMS)** for Brazilian enterprises managing recurring maintenance across facilities (hospitals, academies, factories, hotels, commercial buildings).

> [!IMPORTANT]
> **Scope for V1**: Offline-first local database + core UI + file management + Supabase backend + bidirectional sync engine + personal configuration. **Additions to V1**: Firebase FCM push notifications for work order assignment, Company parameters admin panel (offline alerts/email notification toggles), and Work orders list with search filters and cursor-based pagination. Excluded from V1: QR code scanning, real-time WebSockets (planned for V2), background sync, and multi-company support.

> [!IMPORTANT]
> **Implementation Methodology**: We build step-by-step: table-by-table, column-by-column, data-source-by-data-source, repository-by-repository, module-by-module, page-by-page. Each component must be verified and aligned before proceeding.

## Documentation Map

| Document | Purpose |
|---|---|
| [Product Vision & Competitors](/docs/cmms/product_vision.md) | Target market, competitor analysis, differentiators |
| [Technology Stack](/docs/cmms/tech_stack.md) | Dependencies, Drift rationale, Cloudflare R2, Supabase setup |
| [Architecture](/docs/cmms/architecture.md) | Offline-first design, data flow, file management, invitation flow, infrastructure |
| [Development Phases](/docs/cmms/development_phases.md) | Phase timeline, hour estimates, verification plan |
| [Resolved Questions](/docs/cmms/resolved_questions.md) | Decision log for past design choices |
| [Internal App Mode Roadmap](/docs/cmms/internal_app_mode_plan.md) | Strategic milestones for completing AppMode.internal first |
| [V2 Feature Roadmap](/docs/cmms/v2_features.md) | Scope and details for V2 features |

## Related Documentation

| Document | Purpose |
|---|---|
| [Database Schema](/docs/schema/index.md) | ERD, common columns, and per-table schema files |
| [Database Rules](/docs/database/) | RLS policies and business rules per table |
| [Architect Rules](file:/.agents/rules/architect.md) | Folder structure, DI, routing conventions |
| [Feature Rules](file:/.agents/rules/feature.md) | Data/domain layer patterns and handlers |
| [Database Agent Rules](file:/.agents/rules/database.md) | Schema update enforcement and migration rules |
