# assets

Equipment or physical property items requiring maintenance.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `area_id` | UUID | NO | - | FK → `areas.id` (Cascade) |
| `category_id` | UUID | YES | - | FK → `categories.id` (Set Null). Soft delete of the category is blocked if any active asset references it. |
| `parent_asset_id` | UUID | YES | - | Self FK for nested sub-assets (Set Null) |
| `name` | VARCHAR(255) | NO | - | Equipment description |
| `code` | VARCHAR(100) | YES | - | System code (Unique per company and case-insensitive when active) |
| `manufacturer` | VARCHAR(100) | YES | - | Brand |
| `model` | VARCHAR(100) | YES | - | Model |
| `serial_number` | VARCHAR(100) | YES | - | Serial (Unique per company and case-insensitive when active) |
| `install_date` | DATE | YES | - | Installation date |
| `warranty_expiration` | DATE | YES | - | Warranty end date |
| `revision_forecast` | DATE | YES | - | Predicted next revision |
| `status` | VARCHAR(50) | NO | 'active' | active / inactive / decommissioned |
| `criticality` | VARCHAR(50) | NO | 'medium' | low / medium / high / mission_critical |
| `notes` | VARCHAR(2000) | YES | - | Additional notes |

## Constraints

* `chk_assets_name_not_empty`: `CHECK (length(trim(name)) > 0)` prevents empty or whitespace-only asset names.
* `chk_assets_not_self_parent`: `CHECK (parent_asset_id IS NULL OR parent_asset_id != id)` prevents an asset from referencing itself as parent.

## Deletion Rules

* **Hard Deletes**: Prohibited by the general `prevent_delete()` trigger.
* **Soft Deletes**: Blocked if there are open work orders or active sub-assets associated with the asset:
  * Trigger: `tr_prevent_delete_assets_with_relations` (`check_asset_before_delete()`)
  * Open Work Orders Check: Blocked if any work orders associated with this asset have `status != 'completed'` and `deleted_at IS NULL`.
  * Active Child Assets Check: Blocked if any asset referencing this asset as `parent_asset_id` has `deleted_at IS NULL`.

