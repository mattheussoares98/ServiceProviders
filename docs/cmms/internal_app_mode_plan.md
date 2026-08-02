# Plan: Complete Internal App Mode (`AppMode.internal`) First

## Overview
This document outlines the strategic roadmap for completing **Internal Mode** (`AppMode.internal`) in full before continuing work on **Provider Mode** (`AppMode.provider`). Both modes are treated as distinct applications residing within the same codebase.

All features, workflows, permissions, UI components, and automated tests for **Internal Mode** will be completed and validated first.

---

## Internal Mode Roadmap & Milestones

### Milestone 1.1: Work Order Execution & Checklist Completion
- **Work Order Details & Execution**:
  - Execution timer (`FormattedDurationTimerText`) with real-time ticking, adaptive unit formatting (months, weeks, days, hours, minutes, seconds), and `RepaintBoundary` performance isolation.
  - Photo and document attachments per Work Order.
  - Digital sign-off upon completion.
- **Checklist Responses**:
  - Dynamic rendering of checklist items inside Work Order execution.
  - Item-level attachments, pass/fail status, numeric readings, and mandatory field validation.

### Milestone 1.2: Checklists & Maintenance Plans Modules
- **Checklists Module (`lib/features/checklists`)**:
  - Route checklist screens (`/checklists`, `/checklists/create_update`) in `lib/routing/routes.dart`.
  - Add Checklists drawer item (`ChecklistsDrawerItem`) to `HomeDrawer`.
  - Build template management (CRUD for templates and items).
- **Maintenance Plans Module (`lib/features/maintenance_plans`)**:
  - Route maintenance plan screens (`/maintenance_plans`, `/maintenance_plans/create_update`) in `lib/routing/routes.dart`.
  - Add Maintenance Plans drawer item (`MaintenancePlansDrawerItem`) to `HomeDrawer`.
  - Implement periodic scheduling triggers (time-based & meter-based) and automated Work Order generation.

### Milestone 1.3: Inventory & Spare Parts Control
- **Spare Parts Catalog & Stock Levels**:
  - Data models, repositories, and UI for managing spare parts inventory.
  - Stock movement tracking (check-in, check-out, minimum stock alerts).
- **Work Order Integration**:
  - Link consumed spare parts directly to Work Orders during execution.
  - Deduct stock quantities upon Work Order completion.

### Milestone 1.4: Sectors, Categories & RBAC Administration
- **Sectors & Categories Management**:
  - Dedicated CRUD screens and navigation drawer items for sectors/cost centers and category hierarchies.
- **Role-Based Access Control (RBAC)**:
  - Enforce permissions per resource type (`ResourceType`) in drawer items, page views, and API calls.
  - Complete tests for permission guards and group permissions.

---

## Phase 2: Provider App Mode (`AppMode.provider`)
*Deferred until Phase 1 (Milestones 1.1 - 1.4) is 100% complete and verified with automated unit and integration tests.*
