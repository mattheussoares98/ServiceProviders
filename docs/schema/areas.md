# areas

Internal zones/rooms within a location.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `location_id` | UUID | NO | - | FK → `locations.id` (Cascade) |
| `name` | VARCHAR(255) | NO | - | Zone name (Unique per location and case-insensitive when active) (e.g. Sala 102) |
| `floor` | VARCHAR(50) | YES | - | Floor level |
| `description` | VARCHAR(1000) | YES | - | Zone details |

## Deletion Rules

* **Hard Deletes**: Prohibited by the general `prevent_delete()` trigger.
* **Soft Deletes**: Blocked if there are active assets or open work orders associated with the area:
  * Trigger: `tr_prevent_delete_areas_with_relations`
  * Active Assets Check: Blocked if any assets in the area have `deleted_at IS NULL`.
  * Open Work Orders Check (via asset): Blocked if any work orders linked to assets in this area have `status != 'completed'` and `deleted_at IS NULL`.
  * Open Work Orders Check (direct): Blocked if any work orders with `area_id = this area` and `asset_id IS NULL` have `status != 'completed'` and `deleted_at IS NULL`.

