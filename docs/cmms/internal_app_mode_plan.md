# Plan: Complete Internal App Mode (`AppMode.internal`) First

## Overview
This document outlines the strategic roadmap for completing **Internal Mode** (`AppMode.internal`) in full before continuing work on **Provider Mode** (`AppMode.provider`). Both modes are treated as distinct applications residing within the same codebase.

All features, workflows, permissions, UI components, and automated tests for **Internal Mode** will be completed and validated first.

---

## Internal Mode Roadmap & Milestones

### Milestone 1.1: Work Order Execution (Core MVP) — ✅ IMPLEMENTED
- **Work Order Details & Execution**:
  - ✅ Execution timer (`FormattedDurationTimerText`) with real-time ticking, adaptive unit formatting, and `RepaintBoundary` performance isolation.
  - ✅ Photo and document attachments per Work Order (`lib/features/attachments`).
  - ✅ Digital sign-off upon completion.
- **Checklist Responses [ON HOLD - Deferred]**:
  - *Status: ON HOLD (Will resume when explicitly requested for future versions).*

### Milestone 1.2: Checklists & Maintenance Plans Modules [ON HOLD - Deferred]
> ⚠️ **Status: ON HOLD** — Template management, standalone checklists, and automated maintenance plans are deferred for future releases and not required for v1.

### Milestone 1.3: Inventory & Stock Control [ON HOLD - Deferred]
> ⚠️ **Status: ON HOLD** — Inventory stock management and product usage tracking are deferred for future releases.


### Milestone 1.4: Sectors, Categories & RBAC Administration — 🟡 PARTIALLY IMPLEMENTED
- **Sectors & Categories Management**:
  - ✅ Data, domain, cubit, and pages for Sectors (`lib/features/sectors`) and Categories (`lib/features/categories`).
- **Role-Based Access Control (RBAC)**:
  - ✅ ResourceType, permissions, and group permissions implemented.
  - ✅ Dual App Mode (`AppMode.internal` & `AppMode.provider`), `ModeSwitcherCubit`, and mode-aware login routing implemented.
  - ✅ Service Provider Backend (Supabase migrations, remote data source, repository, cubit, and `CreateServiceProviderCompanyPage`).

---

## Phase 2: Provider App Mode (`AppMode.provider`) UI
*Provider Mode Backend/Cubit layers are already built. UI pages and provider-specific Work Order views remain to be completed.*

