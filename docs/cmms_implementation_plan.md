# ServicePro CMMS — Implementation Plan

A **Computerized Maintenance Management System (CMMS)** for enterprises that manage recurring maintenance work (daily, weekly, monthly) across facilities such as hospitals, academies, factories, hotels, and commercial buildings.

> [!IMPORTANT]
> **Scope for V1**: Offline-first local database + core UI + file management + Supabase backend + bidirectional sync engine. **Excluded** from V1: QR code scanning, real-time WebSockets, background sync, push notifications, and multi-company support.

> [!IMPORTANT]
> **Implementation Methodology**: We will build this project step-by-step together: table-by-table, column-by-column, data-source-by-data-source, repository-by-repository, module-by-module, page-by-page, and so on. No build implementations are allowed. Each component must be verified and aligned before proceeding.


---

## 1. Product Vision & Competitor Analysis

### 1.1 Target Market
Brazilian enterprises that need to manage preventive and corrective maintenance across one or more facilities. Main user personas:
- **Facility Manager** — creates plans, assigns work, monitors KPIs
- **Technician** — receives work orders, fills checklists, attaches photos/signatures
- **Admin** — manages users, roles, and company settings

### 1.2 Competitor Landscape

| Feature | Fracttal One | Infraspeak | Leankeep | Our App (ServicePro) |
|---|---|---|---|---|
| Work Orders | ✅ | ✅ | ✅ | ✅ V1 |
| Asset Management | ✅ | ✅ | ✅ | ✅ V1 |
| Preventive Maintenance Plans | ✅ | ✅ | ✅ | ✅ V1 |
| Checklists & Inspections | ✅ | ✅ | ✅ | ✅ V1 |
| Offline Mode | ✅ (mobile) | ❌ | ✅ (mobile) | ✅ V1 (full offline-first) |
| File Attachments (photos/PDFs) | ✅ | ✅ | ✅ | ✅ V1 |
| Signature Capture | ✅ | ❌ | ✅ | ⏳ V2 |
| QR Code / NFC Scanning | ✅ | ✅ | ✅ | ⏳ V2 |
| IoT Sensor Integration | ✅ | ✅ | ❌ | ⏳ Future |
| AI Assistant | ✅ | ✅ (Gear AI) | ❌ | ⏳ Future |
| Multi-tenancy | ✅ | ✅ | ✅ | ✅ V1 |
| Multi-company per user | ✅ | ✅ | ✅ | ⏳ V3 |
| Real-time Dashboards / KPIs | ✅ | ✅ | ✅ | ⏳ V2 |
| Push Notifications | ✅ | ✅ | ✅ | ⏳ V2 (Firebase FCM) |

### 1.3 Differentiator Strategy
1. **True offline-first** — the app works 100% without internet from day one. Competitors only partially support offline.
2. **Brazilian market focus** — all UI in pt-BR, PMOC compliance, CPF/CNPJ support. Future i18n-ready via `.hardcoded` extension on all user-visible strings.
3. **Cost-effective file storage** — Cloudflare R2 with zero egress fees vs. competitors' expensive cloud storage.

---

## 2. Technology Stack

### 2.1 Existing Stack (Preserved)

| Layer | Technology | Status |
|---|---|---|
| Framework | Flutter (Dart SDK ≥3.10.0) | ✅ Existing |
| Architecture | Clean Architecture (Data → Domain → Presentation) | ✅ Existing |
| State Management | `flutter_bloc` — Cubit pattern | ✅ Existing |
| DI / IoC | `get_it` + `injectable` | ✅ Existing |
| Navigation | `auto_route` | ✅ Existing |
| HTTP Client | `dio` + custom `HttpClient` | ✅ Existing |
| Auth Backend | Supabase Auth (via `supabase_flutter`) | ✅ Existing |
| Linting | `leancode_lint` | ✅ Existing |
| Testing | `flutter_test`, `bloc_test`, `mocktail`, `faker`, `patrol` | ✅ Existing |
| Localization prep | `.hardcoded` extension on all user-facing strings | ✅ Existing |

### 2.2 New Dependencies to Add

| Package | Purpose | Version (approx.) |
|---|---|---|
| `drift` | Local SQLite database (type-safe, reactive) — **single local DB** | ^2.22.0 |
| `drift_dev` (dev) | Code generation for Drift tables | ^2.22.0 |
| `sqlite3_flutter_libs` | SQLite native binaries for mobile/desktop | ^0.5.0 |
| `path` | Path manipulation for DB file location | ^1.9.0 |
| `uuid` | Client-side UUID generation for offline entities | ^4.5.1 |
| `minio` | S3-compatible client for Cloudflare R2 uploads | ^3.8.0 |
| `connectivity_plus` | Network status monitoring | ^6.1.1 |
| `image_compress_plus` | Image compression before local storage & upload | ^2.2.0 |
| `path_provider` | App sandbox directory for file storage | ✅ Already present |
| `image_picker` | Camera/gallery for photo attachments | ✅ Already present |
| `file_picker` | PDF/document selection | ^8.1.6 |
| `signature` | Digital signature capture (V2) | ⏳ V2 |
| `mobile_scanner` | QR code scanning (V2) | ⏳ V2 |

> [!IMPORTANT]
> **Why Drift?** After researching all major Flutter local databases (Isar, Drift, ObjectBox, Hive, sqflite, Floor), **Drift is the clear winner** for a CMMS app:
>
> | Database | Type | Maintenance Status | Verdict |
> |---|---|---|---|
> | **Drift** | SQL (SQLite) | ✅ Actively maintained | **✅ Our choice** — relational joins, migrations, reactive `.watch()` |
> | Isar | NoSQL | ❌ **Abandoned** by original author | ❌ High risk for production. Community forks exist but unreliable |
> | ObjectBox | NoSQL | ✅ Active | ❌ Not open-source, NoSQL doesn't fit relational CMMS data |
> | Hive (CE) | NoSQL | ⚠️ Community-maintained | ❌ Poor for complex queries and relationships |
> | sqflite | SQL (SQLite) | ✅ Stable | ❌ Too low-level, no type safety, manual boilerplate |
> | Floor | SQL (SQLite) | ✅ Active | ⚠️ Good alternative but less features than Drift |
>
> **Isar is NOT recommended.** It has been abandoned by its creator. Community forks (`isar_community`, `isar_plus`) exist but have compatibility issues (e.g., Android 16KB page size). Do not start a new production project with Isar.

> [!NOTE]
> **Drift IS SQLite.** It is a single local database — one `.sqlite` file on disk. Drift is just a type-safe Dart wrapper around SQLite with code generation, reactive queries, and migrations. There is no "Drift + SQLite" as two separate databases. It is one database.

### 2.3 File Storage: Cloudflare R2

| Aspect | Decision |
|---|---|
| Provider | **Cloudflare R2** (S3-compatible, zero egress fees) |
| Upload flow | Flutter → Supabase Edge Function (generates presigned PUT URL) → Flutter uploads directly to R2 |
| Pricing | ~$0.015/GB/month storage, $0 egress, free tier: 10M reads/month |
| Flutter client | `minio` package pointing to R2 endpoint |
| Security | Never store R2 credentials in the app. All uploads go through presigned URLs generated by a Supabase Edge Function |
| Local files | Copied into app sandbox (`path_provider`) with local path stored in Drift DB |
| **Image compression** | Use `image_compress_plus` to compress images before saving locally. Target: 1920px max resolution, quality 75-80, WebP format. This reduces storage and bandwidth while maintaining good visual quality |

### 2.4 Backend: Supabase

| Concern | Approach |
|---|---|
| Auth | Supabase Auth (email/password + Google OAuth) — **already implemented** |
| Database | Supabase PostgreSQL for the remote source of truth |
| Multi-tenancy | `company_id` column on every table + RLS policies |
| Edge Functions | Presigned URL generation for R2, user invitation flow |
| Real-time | ⏳ V2 — Supabase WebSocket channels for permission changes |
| Notifications | ⏳ V2 — Firebase FCM for push notifications |

### 2.5 Company Creation (V1)

> [!NOTE]
> In V1, company creation is a **manual process**. The customer contacts the administrator (you) to negotiate pricing and create the company. There is no self-service sign-up flow for companies. Only user invitations within an existing company are automated.

---

## 3. Domain Model — Core Entities

### 3.1 Entity Relationships

The table below shows how each entity connects to others. Read it as: "Entity A → connects to → Entity B (relationship type)."

| Parent Entity | Child Entity | Relationship | Description |
|---|---|---|---|
| **Company** | Location | one-to-many | A company has many locations (buildings, facilities) |
| **Company** | UserProfile | one-to-many | A company employs many users |
| **Company** | Category | one-to-many | A company defines its own equipment categories |
| **Company** | PermissionGroup | one-to-many | A company can create custom permission groups |
| **Location** | Area | one-to-many | A location contains many areas (rooms, floors) |
| **Area** | Asset | one-to-many | An area holds many assets (equipment) |
| **Asset** | WorkOrder | one-to-many | An asset can have many work orders over time |
| **Asset** | Category | many-to-one | An asset belongs to one category |
| **WorkOrder** | Task | one-to-many | A work order contains subtasks |
| **WorkOrder** | Attachment | one-to-many | A work order can have photos, PDFs, etc. |
| **WorkOrder** | UserProfile | many-to-one | A work order is assigned to one user |
| **WorkOrder** | Location | many-to-one | A work order happens at one location |
| **WorkOrder** | ChecklistTemplate | many-to-one (optional) | A work order can use one checklist |
| **MaintenancePlan** | WorkOrder | one-to-many | A plan generates work orders on schedule |
| **MaintenancePlan** | Asset | many-to-one (optional) | A plan targets a specific asset |
| **ChecklistTemplate** | ChecklistItem | one-to-many | A template has many items (steps) |
| **UserProfile** | PermissionGroup | many-to-one | A user belongs to one permission group |

### 3.2 What is a ChecklistTemplate?

A **ChecklistTemplate** is a reusable "recipe" of inspection steps. Think of it as a form that a technician fills out during a work order.

**Example**: Template called "Inspeção de Ar Condicionado"

| # | ChecklistItem (step) | Type | Required? |
|---|---|---|---|
| 1 | "Filtro limpo?" | boolean (Sim/Não) | Yes |
| 2 | "Temperatura de saída (°C)" | number | Yes |
| 3 | "Foto do filtro" | photo | No |
| 4 | "Nível de ruído" | selection (Baixo/Médio/Alto) | Yes |
| 5 | "Observações adicionais" | text | No |

When a work order uses this template, the technician fills in each step. The completed checklist is saved with the work order for historical records.

### 3.3 Entity Definitions

> [!NOTE]
> **Soft Delete Strategy**: Almost every entity below includes a `deletedAt` timestamp. To support reliable offline synchronization, hard deletes are forbidden. Deleted records are flagged locally and remotely, allowing the sync engine to propagate deletion before the record is purged.
> **Permissions Enum**: Permissions are modeled as a strict Dart `Permission` enum (rather than raw strings) to prevent typos.
> **Drift Local Indexes**: Drift tables will mirror database indexes using `@Index` annotations on columns like `companyId`, `status`, and `assignedToId` to ensure high performance on mobile devices.

#### Company (Multi-Tenant Root)
```
Company {
  id: UUID (PK)
  name: String
  cnpj: String?
  logoUrl: String?
  isActive: bool
  createdAt: DateTime
  updatedAt: DateTime
  deletedAt: DateTime?
}
```

#### UserProfile (extends existing UserEntity)
```
UserProfile {
  id: UUID (PK, from Supabase Auth)
  companyId: UUID (FK → Company)
  name: String
  email: String
  phone: String?
  permissionGroupId: UUID (FK → PermissionGroup)
  avatarUrl: String?
  isActive: bool
  createdAt: DateTime
  updatedAt: DateTime
  deletedAt: DateTime?
}
```

#### PermissionGroup (replaces Role)
```
PermissionGroup {
  id: UUID (PK)
  companyId: UUID (FK → Company)
  name: String                    // e.g. "Administrador", "Gestor", "Técnico"
  permissions: List<Permission>   // List of Permission enum values (prevents typos)
  isDefault: bool                 // true = system-provided group (cannot be deleted)
  createdAt: DateTime
  deletedAt: DateTime?
}
```

**Default Permission Groups** (created automatically for every company):

| Group | Key Permissions |
|---|---|
| **Administrador** | Full access: manage users, company settings, all CRUD |
| **Gestor** | Create/edit work orders, manage assets, assign technicians, view reports |
| **Técnico** | View assigned work orders, update status, add attachments, fill checklists |

Custom groups can be created by the Admin and are available only within that company.

#### Location
```
Location {
  id: UUID (PK)
  companyId: UUID (FK → Company)
  name: String                    // e.g. "Hospital Central", "Academia Norte" (UNIQUE per company)
  address: String?
  city: String?
  state: String?
  isActive: bool
  createdAt: DateTime
  updatedAt: DateTime
  deletedAt: DateTime?
}
```

#### Area
```
Area {
  id: UUID (PK)
  locationId: UUID (FK → Location)
  companyId: UUID (FK → Company)
  name: String                    // e.g. "Sala de Máquinas", "Recepção"
  floor: String?
  description: String?
  createdAt: DateTime
  updatedAt: DateTime
  deletedAt: DateTime?
}
```

#### Category
```
Category {
  id: UUID (PK)
  companyId: UUID (FK → Company)
  name: String                    // e.g. "Ar Condicionado", "Elétrica", "Hidráulica" (UNIQUE per company)
  description: String?
  color: String?                  // hex color for UI tags
  createdAt: DateTime
  deletedAt: DateTime?
}
```

#### Asset
```
Asset {
  id: UUID (PK)
  companyId: UUID (FK → Company)
  areaId: UUID (FK → Area)
  categoryId: UUID (FK → Category)
  parentAssetId: UUID? (FK → Asset) // Supports hierarchical equipment structure
  name: String                    // e.g. "Ar Condicionado Split 12000 BTU"
  code: String?                   // internal equipment code (UNIQUE per company)
  manufacturer: String?
  model: String?
  serialNumber: String?           // equipment serial number (UNIQUE per company)
  installDate: DateTime?
  warrantyExpiration: DateTime?
  revisionForecast: DateTime?     // predicted next revision date — enables proactive notifications
  status: AssetStatus             // enum: active, inactive, decommissioned
  criticality: AssetCriticality   // enum: low, medium, high, missionCritical
  notes: String?
  createdAt: DateTime
  updatedAt: DateTime
  deletedAt: DateTime?
}
```

> [!TIP]
> The `revisionForecast` field allows the app to query all assets approaching their next revision date and send notifications (V2) or display warnings in the dashboard. Example query: "Show all assets where `revisionForecast` is within the next 7 days."

#### WorkOrder
```
WorkOrder {
  id: UUID (PK)
  companyId: UUID (FK → Company)
  assetId: UUID? (FK → Asset)
  locationId: UUID (FK → Location)
  assignedToId: UUID? (FK → UserProfile)
  createdById: UUID (FK → UserProfile)
  maintenancePlanId: UUID? (FK → MaintenancePlan)
  title: String
  description: String?
  priority: Priority              // enum: low, medium, high, critical
  status: WorkOrderStatus         // enum: open, in_progress, on_hold, completed, cancelled
  type: WorkOrderType             // enum: corrective, preventive, inspection
  scheduledDate: DateTime?
  startedAt: DateTime?
  completedAt: DateTime?
  estimatedDuration: int?         // minutes
  actualDuration: int?            // minutes
  laborCost: double?              // Estimated/actual labor cost
  partsCost: double?              // Parts replacement cost
  totalCost: double?              // laborCost + partsCost
  notes: String?
  createdAt: DateTime
  updatedAt: DateTime
  deletedAt: DateTime?
}
```

#### Task (Subtask of a WorkOrder)
```
Task {
  id: UUID (PK)
  workOrderId: UUID (FK → WorkOrder)
  companyId: UUID (FK → Company)
  title: String
  description: String?
  isCompleted: bool
  completedAt: DateTime?
  completedById: UUID? (FK → UserProfile)
  sortOrder: int
  createdAt: DateTime
  updatedAt: DateTime
  deletedAt: DateTime?
}
```

#### MaintenancePlan (Recurring Schedules)
```
MaintenancePlan {
  id: UUID (PK)
  companyId: UUID (FK → Company)
  assetId: UUID? (FK → Asset)
  locationId: UUID? (FK → Location)
  title: String
  description: String?
  frequency: Frequency            // enum: daily, weekly, biweekly, monthly, quarterly, semiannual, annual
  dayOfWeek: int?                 // 1-7 for weekly plans
  dayOfMonth: int?                // 1-31 for monthly plans
  monthOfYear: int?               // 1-12 for annual plans
  checklistTemplateId: UUID? (FK → ChecklistTemplate)
  assignedToId: UUID? (FK → UserProfile)
  priority: Priority
  isActive: bool
  lastGeneratedAt: DateTime?
  nextDueDate: DateTime?
  createdAt: DateTime
  updatedAt: DateTime
  deletedAt: DateTime?
}
```

#### ChecklistTemplate
```
ChecklistTemplate {
  id: UUID (PK)
  companyId: UUID (FK → Company)
  name: String                    // e.g. "Inspeção de Ar Condicionado"
  description: String?
  categoryId: UUID? (FK → Category)
  createdAt: DateTime
  updatedAt: DateTime
  deletedAt: DateTime?
}
```

#### ChecklistItem
```
ChecklistItem {
  id: UUID (PK)
  templateId: UUID (FK → ChecklistTemplate)
  companyId: UUID (FK → Company)
  label: String                   // e.g. "Filtro limpo?"
  type: ChecklistItemType         // enum: boolean, text, number, photo, selection
  isRequired: bool
  options: List<String>?          // for 'selection' type
  sortOrder: int
  createdAt: DateTime
  deletedAt: DateTime?
}
```

#### Attachment
```
Attachment {
  id: UUID (PK)
  workOrderId: UUID (FK → WorkOrder)
  companyId: UUID (FK → Company)
  uploadedById: UUID (FK → UserProfile)
  fileName: String
  fileType: FileType              // enum: image, pdf, document, signature
  localPath: String?              // local sandbox path (offline)
  remoteUrl: String?              // R2 URL after sync
  fileSizeBytes: int?
  isCompressed: bool              // whether the file was compressed locally
  uploadStatus: UploadStatus      // enum: pending, uploaded, failed
  createdAt: DateTime
  deletedAt: DateTime?
}
```

#### WorkOrderChangeRequest
```
WorkOrderChangeRequest {
  id: UUID (PK)
  workOrderId: UUID (FK → WorkOrder)
  companyId: UUID (FK → Company)
  requestedById: UUID (FK → UserProfile)
  changeType: WorkOrderChangeType  // enum: add_task, add_attachment, update_notes, fill_checklist
  changeData: String               // JSON serialized content of the change
  status: ChangeRequestStatus      // enum: pending, approved, rejected
  reviewedById: UUID?              // FK → UserProfile (Gestor/Admin who approved/rejected)
  rejectionReason: String?
  createdAt: DateTime
  updatedAt: DateTime
  deletedAt: DateTime?
}
```

#### CompanyParameter
```
CompanyParameter {
  id: UUID (PK)
  companyId: UUID (FK → Company)
  maxOfflineDurationHours: int     // Alert threshold: hours offline before warning dialog
  maxOfflinePendingRequests: int   // Alert threshold: pending sync requests before warning dialog
  createdAt: DateTime
  updatedAt: DateTime
}
```

#### SyncAuditLog
```
SyncAuditLog {
  id: UUID (PK)
  companyId: UUID (FK → Company)
  userProfileId: UUID (FK → UserProfile)
  entityType: String               // e.g. 'work_order', 'task', 'attachment'
  entityId: UUID
  operation: String                // e.g. 'create', 'update', 'delete'
  syncedAt: DateTime
}
```

#### WorkOrderHistory
```
WorkOrderHistory {
  id: UUID (PK)
  workOrderId: UUID (FK → WorkOrder)
  companyId: UUID (FK → Company)
  userId: UUID (FK → UserProfile)
  action: String                  // e.g. "status_change", "assignment", "attachment_added"
  oldValue: String?
  newValue: String?
  createdAt: DateTime
}
```

---

## 4. Architecture — Offline-First Design

### 4.1 Data Flow

```
┌───────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                           │
│  Pages/Widgets → Cubit (BaseCubit) → Use Cases               │
└──────────────────────────┬────────────────────────────────────┘
                           │
┌──────────────────────────▼────────────────────────────────────┐
│  DOMAIN LAYER                                                 │
│  Repository Interface (abstract)                              │
└──────────┬───────────────────────────────────┬────────────────┘
           │                                   │
┌──────────▼──────────┐            ┌───────────▼───────────────┐
│  LOCAL DATA SOURCE  │            │  REMOTE DATA SOURCE       │
│  (Drift / SQLite)   │            │  (Supabase PostgreSQL)    │
│  ═══════════════    │            │  ═══════════════════      │
│  • Source of truth  │            │  • Remote backup          │
│  • Works offline    │            │  • Multi-device sync (V2) │
│  • Reactive .watch()│            │  • Files → Cloudflare R2  │
└─────────────────────┘            └───────────────────────────┘
```

### 4.2 Offline-First Principle: Local DB is the Source of Truth

1. **All writes go to Drift first** — the UI never waits for a network call to perform CRUD.
2. **Reactive queries** — UI uses Drift's `.watch()` streams so the interface updates instantly when local data changes.
3. **Bidirectional Sync Engine in V1** — A background synchronizer is implemented in V1 to sync local database events (inserts, updates, soft deletes) to Supabase and pull remote changes using a First-In, First-Out (FIFO) queue logic.

### 4.3 What Can Be Done Offline?

Not everything should be editable offline. Allowing unrestricted offline edits creates difficult conflict resolution problems. Here is the strategy:

| Operation | Offline? | Rule |
|---|---|---|
| **Create** a work order | ✅ Yes | UUID generated locally. Syncs when online (V2). |
| **Edit** an open work order **you created** | ✅ Yes | Safe because you own it. |
| **Edit** an open work orde### 4.4 Handling Closed Work Orders (FIFO Sync & Change Requests)

To maintain historical integrity and prevent tampering with finalized data, edits to closed work orders follow a strict approval workflow:
1. **Direct Updates Locked**: Once a `WorkOrder` status is set to `completed` or `cancelled`, it cannot be directly edited/updated in the database by any normal user.
2. **Database Trigger Redirection**: Incoming sync writes or updates on a closed work order (including adding tasks or attachments) are intercepted by a database trigger in Supabase (or locally handled in Drift). The trigger automatically routes the edit details into the `work_order_change_requests` table and cancels the original update, allowing the FIFO sync queue to complete successfully without errors.
3. **Cross-User Edits Allowed**: Because all edits on closed work orders are redirected to change requests, the app can safely allow users to edit/close work orders created by other users. If a conflict occurs (e.g., A closes it while B is offline editing it), B's offline edits will automatically convert into change requests when synced.
4. **Offline Alert Dialogs**: Technicians working offline can be notified of unsynced items. If the device remains offline for a set time (e.g., `maxOfflineDurationHours`) or the local queue exceeds a specific count (e.g., `maxOfflinePendingRequests`), the app will display a warning dialog. These alert thresholds are configurable per company via the `company_parameters` table.
5. **Admin Approval Queue**: Gestores and Admins see a queue of pending requests:
   - **Approve**: Reopens the work order temporarily, merges the requested changes (adding the items/files), and closes the order again.
   - **Reject**: Rejects the request with an optional reason, leaving the closed order intact.
6. **No Data Loss**: Even though edits are blocked directly, the technician's input is saved in the database as a request, preventing work from being lost.

### 4.5 File Management Strategy

Here is how photos/PDFs are handled step by step:

1. **User picks a file** — via camera, gallery, or file picker
2. **Image compression** — if it's an image, `image_compress_plus` compresses it (max 1920px, quality 75-80, WebP format). This reduces a 5MB photo to ~300-500KB while maintaining good visual quality
3. **File copied to app sandbox** — using `path_provider`, the file is moved into the app's secure local directory
4. **Attachment record saved to Drift** — with `localPath`, `uploadStatus: pending`
5. **App works fully offline at this point** — the file is visible in the UI from the local path
6. **(V2) When online** — the file is uploaded to Cloudflare R2 via a presigned URL, and the `remoteUrl` + `uploadStatus: uploaded` are saved

> [!NOTE]
> PDF and document files are NOT compressed — only images. The `isCompressed` flag on the Attachment entity tracks whether compression was applied.

### 4.6 User Invitation Flow

Supabase supports inviting users by email via the Admin API. Here is the planned flow:

1. **Admin clicks "Convidar Usuário"** in the app
2. **App calls a Supabase Edge Function** with the invitee's email and the company's `company_id`
3. **Edge Function calls `auth.admin.inviteUserByEmail()`** — this sends a magic link email to the invitee. The `company_id` is attached as `user_metadata`
4. **Invitee receives email** → clicks the link → is redirected to the app
5. **If the user is NEW**: They land on a "Set Password" screen. After setting their password, a `user_profiles` row is automatically created (via a Supabase trigger) linking them to the company
6. **If the user ALREADY EXISTS**: The invite link still works, but the trigger checks if they already have a profile and links them to the new company

> [!IMPORTANT]
> The service role key (required for `inviteUserByEmail`) is **never** exposed in the Flutter app. It lives only in the Supabase Edge Function.

### 4.7 New Core Infrastructure

#### Drift Database Setup (Single Local Database)
```
lib/core/clients/local/drift/
├── app_database.dart              # Main database class, all tables, migrations
├── app_database.g.dart            # Generated by drift_dev
├── tables/                        # One file per table definition
│   ├── companies_table.dart
│   ├── locations_table.dart
│   ├── areas_table.dart
│   ├── assets_table.dart
│   ├── work_orders_table.dart
│   ├── tasks_table.dart
│   ├── maintenance_plans_table.dart
│   ├── checklist_templates_table.dart
│   ├── checklist_items_table.dart
│   ├── attachments_table.dart
│   ├── categories_table.dart
│   ├── permission_groups_table.dart
│   ├── user_profiles_table.dart
│   ├── work_order_change_requests_table.dart
│   ├── company_parameters_table.dart
│   ├── sync_audit_logs_table.dart
│   └── work_order_history_table.dart  # Track status changes and updates
└── daos/                          # Data Access Objects
    ├── work_order_dao.dart
    ├── asset_dao.dart
    ├── maintenance_plan_dao.dart
    ├── checklist_dao.dart
    ├── work_order_change_request_dao.dart
    └── work_order_history_dao.dart
```

> [!NOTE]
> All 17 tables live inside a **single `AppDatabase` class** → a **single `.sqlite` file** on disk. Drift tables will declare local `@Index` annotations mirroring PostgreSQL indexes to prevent frame drops on mobile CPUs when searching and filtering.

#### File Storage Client
```
lib/core/clients/remote/storage/
├── storage_client.dart                # Abstract interface for file operations
└── r2_storage_client.dart             # Cloudflare R2 implementation using minio
```

---

## 5. Feature Folder Structure (V1)

```
lib/features/
├── auth/                              # ✅ Already exists
├── home/                              # ✅ Already exists (shell/dashboard)
├── company/                           # NEW — Company profile & settings
│   ├── data/
│   ├── domain/
│   └── presentation/
├── work_orders/                       # NEW — Core CMMS feature
│   ├── data/
│   │   ├── data_sources/
│   │   │   ├── work_order_local_data_source.dart
│   │   │   └── work_order_remote_data_source.dart
│   │   ├── models/requests/ & responses/
│   │   └── repositories/
│   │       └── work_order_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── work_order.dart
│   │   │   ├── task.dart
│   │   │   ├── work_order_change_request.dart
│   │   │   └── work_order_history.dart
│   │   ├── repositories/
│   │   │   └── work_order_repository.dart
│   │   └── use_cases/
│   │       ├── create_work_order_use_case.dart
│   │       ├── get_work_orders_use_case.dart
│   │       ├── update_work_order_use_case.dart
│   │       ├── delete_work_order_use_case.dart
│   │       ├── complete_work_order_use_case.dart
│   │       ├── create_work_order_change_request_use_case.dart
│   │       ├── get_work_order_change_requests_use_case.dart
│   │       ├── review_work_order_change_request_use_case.dart
│   │       └── get_work_order_history_use_case.dart
│   └── presentation/
│       ├── cubits/
│       │   ├── work_order_list/
│       │   └── work_order_detail/
│       └── pages/
│           ├── work_order_list/
│           └── work_order_detail/
├── assets/                            # NEW — Equipment/Asset management
│   ├── data/
│   ├── domain/
│   └── presentation/
├── locations/                         # NEW — Location & Area management
│   ├── data/
│   ├── domain/
│   └── presentation/
├── maintenance_plans/                 # NEW — Recurring maintenance schedules
│   ├── data/
│   ├── domain/
│   └── presentation/
├── checklists/                        # NEW — Checklist templates & execution
│   ├── data/
│   ├── domain/
│   └── presentation/
├── attachments/                       # NEW — File/photo management
│   ├── data/
│   ├── domain/
│   └── presentation/
├── categories/                        # NEW — Category management
│   ├── data/
│   ├── domain/
│   └── presentation/
└── users/                             # NEW — User/role/permission group management
    ├── data/
    ├── domain/
    └── presentation/
```

---

## 6. Supabase PostgreSQL Schema

### 6.1 Tables

> [!IMPORTANT]
> Every table includes `company_id UUID NOT NULL REFERENCES companies(id)` for multi-tenancy. All RLS policies filter by `company_id` matching the authenticated user's company.

```sql
-- ============================================
-- 1. Companies
-- ============================================
CREATE TABLE companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  cnpj TEXT,
  logo_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 2. Permission Groups (replaces Roles)
-- ============================================
CREATE TABLE permission_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  permissions JSONB NOT NULL DEFAULT '[]',
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 3. User Profiles
-- ============================================
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  permission_group_id UUID REFERENCES permission_groups(id),
  avatar_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 4. Locations
-- ============================================
CREATE TABLE locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  UNIQUE (company_id, name)
);

-- ============================================
-- 5. Areas
-- ============================================
CREATE TABLE areas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  floor TEXT,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 6. Categories
-- ============================================
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  UNIQUE (company_id, name)
);

-- ============================================
-- 7. Assets
-- ============================================
CREATE TABLE assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  area_id UUID NOT NULL REFERENCES areas(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id),
  parent_asset_id UUID REFERENCES assets(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  code TEXT,
  manufacturer TEXT,
  model TEXT,
  serial_number TEXT,
  install_date DATE,
  warranty_expiration DATE,
  revision_forecast DATE,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'decommissioned')),
  criticality TEXT NOT NULL DEFAULT 'medium' CHECK (criticality IN ('low', 'medium', 'high', 'mission_critical')),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  UNIQUE (company_id, serial_number),
  UNIQUE (company_id, code)
);

-- ============================================
-- 8. Checklist Templates
-- ============================================
CREATE TABLE checklist_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  category_id UUID REFERENCES categories(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 9. Checklist Items
-- ============================================
CREATE TABLE checklist_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID NOT NULL REFERENCES checklist_templates(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'boolean' CHECK (type IN ('boolean', 'text', 'number', 'photo', 'selection')),
  is_required BOOLEAN NOT NULL DEFAULT false,
  options JSONB,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 10. Maintenance Plans
-- ============================================
CREATE TABLE maintenance_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  asset_id UUID REFERENCES assets(id),
  location_id UUID REFERENCES locations(id),
  title TEXT NOT NULL,
  description TEXT,
  frequency TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly', 'biweekly', 'monthly', 'quarterly', 'semiannual', 'annual')),
  day_of_week INT,
  day_of_month INT,
  month_of_year INT,
  checklist_template_id UUID REFERENCES checklist_templates(id),
  assigned_to_id UUID REFERENCES user_profiles(id),
  priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  last_generated_at TIMESTAMPTZ,
  next_due_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 11. Work Orders
-- ============================================
CREATE TABLE work_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  asset_id UUID REFERENCES assets(id),
  location_id UUID NOT NULL REFERENCES locations(id),
  assigned_to_id UUID REFERENCES user_profiles(id),
  created_by_id UUID NOT NULL REFERENCES user_profiles(id),
  maintenance_plan_id UUID REFERENCES maintenance_plans(id),
  title TEXT NOT NULL,
  description TEXT,
  priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'on_hold', 'completed', 'cancelled')),
  type TEXT NOT NULL DEFAULT 'corrective' CHECK (type IN ('corrective', 'preventive', 'inspection')),
  scheduled_date TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  estimated_duration INT,
  actual_duration INT,
  labor_cost NUMERIC(10,2),
  parts_cost NUMERIC(10,2),
  total_cost NUMERIC(10,2),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 12. Tasks (Subtasks of Work Orders)
-- ============================================
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  work_order_id UUID NOT NULL REFERENCES work_orders(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  completed_at TIMESTAMPTZ,
  completed_by_id UUID REFERENCES user_profiles(id),
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 13. Attachments
-- ============================================
CREATE TABLE attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  work_order_id UUID NOT NULL REFERENCES work_orders(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  uploaded_by_id UUID NOT NULL REFERENCES user_profiles(id),
  file_name TEXT NOT NULL,
  file_type TEXT NOT NULL CHECK (file_type IN ('image', 'pdf', 'document', 'signature')),
  remote_url TEXT,
  file_size_bytes INT,
  is_compressed BOOLEAN NOT NULL DEFAULT false,
  upload_status TEXT NOT NULL DEFAULT 'pending' CHECK (upload_status IN ('pending', 'uploaded', 'failed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 14. Work Order Change Requests
-- ============================================
CREATE TABLE work_order_change_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  work_order_id UUID NOT NULL REFERENCES work_orders(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  requested_by_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  change_type TEXT NOT NULL CHECK (change_type IN ('add_task', 'add_attachment', 'update_notes', 'fill_checklist')),
  change_data JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewed_by_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 15. Company Parameters
-- ============================================
CREATE TABLE company_parameters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE UNIQUE,
  max_offline_duration_hours INT NOT NULL DEFAULT 2,
  max_offline_pending_requests INT NOT NULL DEFAULT 10,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 16. Sync Audit Logs
-- ============================================
CREATE TABLE sync_audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  user_profile_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  entity_type TEXT NOT NULL,
  entity_id UUID NOT NULL,
  operation TEXT NOT NULL,
  synced_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- 17. Work Order History
-- ============================================
CREATE TABLE work_order_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  work_order_id UUID NOT NULL REFERENCES work_orders(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  old_value TEXT,
  new_value TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 6.2 RLS Policies

```sql
-- Enable RLS on all tables
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE permission_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE checklist_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE checklist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_order_change_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_parameters ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_order_history ENABLE ROW LEVEL SECURITY;

-- Helper function: get the company_id of the authenticated user
CREATE OR REPLACE FUNCTION get_user_company_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT company_id FROM user_profiles WHERE id = auth.uid();
$$;

-- RLS policy pattern (applied to each table with company_id):
-- SELECT
CREATE POLICY "Users read own company data"
  ON work_orders FOR SELECT
  USING (company_id = get_user_company_id());

-- INSERT
CREATE POLICY "Users insert own company data"
  ON work_orders FOR INSERT
  WITH CHECK (company_id = get_user_company_id());

-- UPDATE
CREATE POLICY "Users update own company data"
  ON work_orders FOR UPDATE
  USING (company_id = get_user_company_id())
  WITH CHECK (company_id = get_user_company_id());

-- DELETE
CREATE POLICY "Users delete own company data"
  ON work_orders FOR DELETE
  USING (company_id = get_user_company_id());

-- Same pattern replicated for all 17 tables (including work_order_change_requests, company_parameters, sync_audit_logs, and work_order_history).
-- The companies table has a special policy:
CREATE POLICY "Users read own company"
  ON companies FOR SELECT
  USING (id = get_user_company_id());
```

### 6.3 Indexes

```sql
CREATE INDEX idx_work_orders_company ON work_orders(company_id);
CREATE INDEX idx_work_orders_status ON work_orders(company_id, status);
CREATE INDEX idx_work_orders_assigned ON work_orders(company_id, assigned_to_id);
CREATE INDEX idx_work_orders_scheduled ON work_orders(company_id, scheduled_date);
CREATE INDEX idx_assets_company ON assets(company_id);
CREATE INDEX idx_assets_area ON assets(area_id);
CREATE INDEX idx_assets_revision ON assets(company_id, revision_forecast);
CREATE INDEX idx_tasks_work_order ON tasks(work_order_id);
CREATE INDEX idx_attachments_work_order ON attachments(work_order_id);
CREATE INDEX idx_areas_location ON areas(location_id);
CREATE INDEX idx_maintenance_plans_company ON maintenance_plans(company_id);
CREATE INDEX idx_user_profiles_company ON user_profiles(company_id);
CREATE INDEX idx_permission_groups_company ON permission_groups(company_id);
CREATE INDEX idx_work_order_change_requests_work_order ON work_order_change_requests(work_order_id);
CREATE INDEX idx_work_order_change_requests_status ON work_order_change_requests(company_id, status);
CREATE INDEX idx_company_parameters_company ON company_parameters(company_id);
CREATE INDEX idx_sync_audit_logs_company ON sync_audit_logs(company_id);
CREATE INDEX idx_sync_audit_logs_user ON sync_audit_logs(user_profile_id);
CREATE INDEX idx_work_order_history_work_order ON work_order_history(work_order_id);
CREATE INDEX idx_work_order_history_company ON work_order_history(company_id);
```

### 6.4 Auto-Create Default Permission Groups (Trigger)

```sql
-- Automatically create default permission groups when a new company is inserted
CREATE OR REPLACE FUNCTION create_default_permission_groups()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO permission_groups (company_id, name, permissions, is_default) VALUES
    (NEW.id, 'Administrador', '["*"]', true),
    (NEW.id, 'Gestor', '["work_orders.*","assets.*","locations.*","reports.view"]', true),
    (NEW.id, 'Técnico', '["work_orders.view_assigned","work_orders.update_status","attachments.*","checklists.fill"]', true);
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_create_default_permission_groups
  AFTER INSERT ON companies
  FOR EACH ROW
  EXECUTE FUNCTION create_default_permission_groups();

-- ============================================
-- 6.5 Intercept Closed Work Order Changes (Trigger)
-- ============================================
CREATE OR REPLACE FUNCTION intercept_closed_work_order_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_status TEXT;
  v_company_id UUID;
  v_work_order_id UUID;
BEGIN
  -- Determine parent work order ID and status depending on the table
  IF TG_TABLE_NAME = 'work_orders' THEN
    v_work_order_id := OLD.id;
    v_status := OLD.status;
    v_company_id := OLD.company_id;
  ELSIF TG_TABLE_NAME = 'tasks' THEN
    v_work_order_id := NEW.work_order_id;
    SELECT status, company_id INTO v_status, v_company_id FROM work_orders WHERE id = v_work_order_id;
  ELSIF TG_TABLE_NAME = 'attachments' THEN
    v_work_order_id := NEW.work_order_id;
    SELECT status, company_id INTO v_status, v_company_id FROM work_orders WHERE id = v_work_order_id;
  END IF;

  -- If the work order is closed (completed or cancelled), redirect the changes
  IF v_status IN ('completed', 'cancelled') THEN
    -- Prevent direct update on the main table and redirect payload to requests
    IF TG_TABLE_NAME = 'tasks' THEN
      INSERT INTO work_order_change_requests (work_order_id, company_id, requested_by_id, change_type, change_data)
      VALUES (v_work_order_id, v_company_id, auth.uid(), 'add_task', row_to_json(NEW)::jsonb);
      RETURN NULL; -- Skip the insert/update on the tasks table
    ELSIF TG_TABLE_NAME = 'attachments' THEN
      INSERT INTO work_order_change_requests (work_order_id, company_id, requested_by_id, change_type, change_data)
      VALUES (v_work_order_id, v_company_id, auth.uid(), 'add_attachment', row_to_json(NEW)::jsonb);
      RETURN NULL; -- Skip the insert on the attachments table
    ELSIF TG_TABLE_NAME = 'work_orders' THEN
      INSERT INTO work_order_change_requests (work_order_id, company_id, requested_by_id, change_type, change_data)
      VALUES (v_work_order_id, v_company_id, auth.uid(), 'update_notes', row_to_json(NEW)::jsonb);
      RETURN NULL; -- Skip the update on the work_orders table
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_intercept_work_order_changes
  BEFORE UPDATE ON work_orders
  FOR EACH ROW
  EXECUTE FUNCTION intercept_closed_work_order_changes();

CREATE TRIGGER trg_intercept_tasks_changes
  BEFORE INSERT OR UPDATE ON tasks
  FOR EACH ROW
  EXECUTE FUNCTION intercept_closed_work_order_changes();

CREATE TRIGGER trg_intercept_attachments_changes
  BEFORE INSERT OR UPDATE ON attachments
  FOR EACH ROW
  EXECUTE FUNCTION intercept_closed_work_order_changes();

---

## 7. Backend Documentation Rule

> [!IMPORTANT]
> This is **already enforced** by the Database Specialist Agent rule in [database.md](file:///c:/Development/Projects/ServiceProviders/.agents/rules/database.md).

The rule states:
- **Primary File**: `docs/database_schema.md`
- **Mandatory Update**: After every schema change (table creation, column modification, RLS update), the agent MUST verify and update the documentation
- **Content Requirements**:
  - **Mermaid Diagram**: Visual representation of tables and relationships
  - **Data Dictionary**: For each table, list columns, types, nullability, and description
  - **Security Summary**: Document RLS policies applied to each table
- **Consistency**: Documentation must exactly match the live database state

This means every time any database command is run (new table, new index, new function, column change, RLS policy), the `docs/database_schema.md` file is automatically updated. **No additional configuration needed — it is already an always-on rule.**

---

## 8. Development Phases & Time Estimates

> [!NOTE]
> Estimates assume one developer working ~14 hours/week (2h/day). Adjust proportionally for more time.

### Phase 0: Cleanup & Drift Setup (Week 1) — ~18h

| Task | Est. Hours |
|---|---|
| Remove old Isar code (`isar_db_client.dart`, `user_collection.dart`, Isar dependencies) | 2h |
| Add Drift, uuid, sqlite3_flutter_libs, path dependencies | 1h |
| Create all 17 Drift table definitions (including change requests, parameters, logs, history, and local @Index annotations) | 8h |
| Create `AppDatabase` class with DI registration | 2h |
| Run `build_runner`, verify compilation | 1h |
| Create `docs/database_schema.md` initial version | 4h |

---

### Phase 1: Domain Entities & Data Layer (Weeks 2-4) — ~52h

| Task | Est. Hours |
|---|---|
| Create all domain entities (17 entities + 8 enums and Permission enum) | 9h |
| Repository interfaces for all features | 4h |
| Use cases for CRUD operations (all features) | 12h |
| Local data source implementations (Drift DAOs) | 13h |
| Repository implementations wiring local data sources | 6h |
| Unit tests for DAOs, repositories, use cases | 8h |

---

### Phase 2: Core UI — Work Orders & Assets (Weeks 5-8) — ~56h

| Task | Est. Hours |
|---|---|
| Dashboard (Home) — stats cards, recent work orders, quick actions | 10h |
| Work Order List — filterable list, status chips, priority badges | 8h |
| Work Order Detail — full detail view, tasks checklist, attachments | 10h |
| Create/Edit Work Order — form with pickers | 8h |
| Asset List — searchable grid/list with category filters | 6h |
| Asset Detail — equipment info, revision forecast, linked work orders | 6h |
| Location List — hierarchical view (Location → Areas) | 4h |
| Navigation refactor — tab-based home with bottom navigation | 4h |

---

### Phase 3: File Management & Attachments (Weeks 9-10) — ~28h

| Task | Est. Hours |
|---|---|
| Image compression pipeline (`image_compress_plus`) | 4h |
| File picker integration (camera, gallery, documents) | 4h |
| Copy files to app sandbox + save Attachment records | 4h |
| Image viewer widget (full-screen preview) | 4h |
| PDF viewer widget | 4h |
| Attachment gallery in Work Order Detail | 4h |
| Unit tests | 4h |

---

### Phase 4: Supabase Schema, RLS & Edge Functions (Weeks 11-14) — ~63h

| Task | Est. Hours |
|---|---|
| Create all 17 tables in Supabase (with unique constraints, soft deletes) | 11h |
| Write RLS policies for multi-tenancy | 6h |
| Create helper functions + triggers (permission groups, closed orders, history triggers) | 8h |
| Create indexes for performance | 2h |
| Set up Cloudflare R2 bucket | 2h |
| Build Edge Function: generate presigned URL | 6h |
| Build Edge Function: invite user by email | 6h |
| Create `StorageClient` interface + R2 impl | 4h |
| Remote data sources for each feature | 10h |
| Update repositories to include remote callbacks | 6h |
| Update `docs/database_schema.md` | 4h |

---

### Phase 5: Remaining Features & Polish (Weeks 15-20) — ~87h

| Task | Est. Hours |
|---|---|
| Maintenance Plans CRUD (all layers) | 10h |
| Checklist Templates CRUD (template builder) | 8h |
| Checklist Execution in Work Orders | 6h |
| User & Permission Group Management | 10h |
| User invitation flow (Edge Function + deep links) | 8h |
| Category Management (CRUD + color picker) | 4h |
| Company Settings (profile, logo upload) | 4h |
| Work Order Change Request Approval Queue (Admin UI & FIFO queue integration) | 10h |
| Work Order History log UI integration | 4h |
| Offline Alert Threshold Dialogs UI & parameters integration | 3h |
| Integration tests (Patrol) for critical flows | 10h |
| UI polish, animations, error handling | 10h |

---

### Total V1 Estimate

| Phase | Weeks | Hours |
|---|---|---|
| Phase 0: Cleanup & Drift Setup | 1.5 | ~18h |
| Phase 1: Domain & Data Layers | 3.5 | ~52h |
| Phase 2: Core UI | 4 | ~56h |
| Phase 3: File Management | 2 | ~28h |
| Phase 4: Supabase Backend | 4.5 | ~63h |
| Phase 5: Remaining Features | 6.5 | ~87h |
| **Total** | **22 weeks** | **~304h** |

---

## 9. Resolved Questions

| # | Question | Decision |
|---|---|---|
| Q1 | App Name | "ServicePro" (working title) |
| Q2 | Multi-Company | ❌ Not in V1. Maybe V3 |
| Q3 | Phase Priority | Phase 0 (cleanup Isar → Drift) comes first, then offline-first, then Supabase |
| Q4 | Company Creation | Manual process — customer contacts admin to negotiate and create |
| Q5 | Platforms | User handles platform configuration |
| Q6 | Notifications | Firebase FCM, only after V2 is running |
| Q7 | Local DB | Drift (single SQLite database). Isar is abandoned — do NOT use |
| Q8 | Offline scope | Edits to work orders are allowed. If edited/closed by someone else, subsequent sync requests are automatically redirected to `WorkOrderChangeRequest` by database triggers to avoid conflicts. |
| Q9 | Localization | `.hardcoded` extension on all strings for future i18n |
| Q10 | File compression | `image_compress_plus`, quality 75-80, max 1920px |
| Q11 | DB documentation | Already enforced in `database.md` agent rule → `docs/database_schema.md` |
| Q12 | Permission groups | 3 default groups (Admin, Gestor, Técnico) + custom per company |
| Q13 | revisionForecast | Added to Asset entity for proactive notifications |
| Q14 | Handling Closed Orders | Edits to completed/cancelled orders are saved as change requests in a queue rather than direct updates or requiring pre-approval reopening (to support offline-first). Intercepted automatically by database triggers. |

---

## 10. Verification Plan

### Automated Tests
```bash
# Unit tests (DAOs, repositories, use cases, cubits)
flutter test

# Integration tests (Patrol)
flutter test patrol_test/

# Build runner (ensure code generation is clean)
dart run build_runner build --delete-conflicting-outputs
```

### Manual Verification
- Airplane mode testing: create/edit work orders with WiFi/mobile data OFF
- File attachment: take photo, verify compression, verify files persist after app restart
- Multi-tenant isolation: verify that two test companies cannot see each other's data
- Permission groups: verify that a Técnico cannot access Admin features
- Performance: test with 1000+ work orders in local DB to ensure smooth scrolling
- Invitation flow: invite a new user by email, verify auto-registration and company linking
- Closed Order changes: attempt to edit a completed work order, verify that it creates a change request (local/remote) and does not update the order directly.
- Offline Alerts: remain offline until queue threshold or duration threshold is exceeded, and verify the app displays the configurable warning dialog correctly.

---

## 11. Project Documentation Plan

To ensure consistency and clarity before and during implementation, we will maintain the following structured documentation:

1. **Architecture Guidelines (`docs/architecture.md`)**
   - Details coding standards, layer isolations, and Clean Architecture constraints.
   - Restates rules for using context extensions (e.g., `context.colorScheme`), custom colors, controller hooks (`HookWidget`), and page line limitations (<100 lines).

2. **Database Schema (`docs/database_schema.md`)**
   - A complete reference of Drift tables, Supabase tables, indexes, triggers, and Row Level Security (RLS) policies.
   - Includes a Mermaid ERD diagram representing all entity relationships.
   - Mandatory update on every schema change (enforced via DB specialist).

3. **API Contracts (`docs/api_endpoints.md`)**
   - Details API endpoints for Supabase Edge Functions (invitations, R2 presigned URLs, and synchronization hooks).
   - Documents request and response body JSON models and error handling codes.

4. **Offline Sync & FIFO Queue Protocol (`docs/sync_protocol.md`)**
   - Documents the sync mechanism, local queue storage, conflicts resolution (e.g., handling rejected change requests on closed orders), and internet-recovery triggers.

5. **UI & Design Tokens (`docs/ui_style_guide.md`)**
   - Outlines style guidelines, visual rules (dark mode, gradients, HSL colors), typography, and hook-based controller structures.
   - Lists predefined Portuguese user-visible strings (`.hardcoded`) for system status/labels (e.g., "Aguardando aprovação", "Finalizado").
