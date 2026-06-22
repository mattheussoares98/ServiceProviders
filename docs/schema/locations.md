# locations

Facilities/sites managed by a company.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(255) | NO | - | Facility name (Unique per company and case-insensitive when active) |
| `address` | VARCHAR(500) | YES | - | Street name |
| `number` | VARCHAR(20) | YES | - | Street/building number |
| `complement` | VARCHAR(255) | YES | - | Address complement |
| `neighborhood` | VARCHAR(100) | YES | - | Neighborhood |
| `city` | VARCHAR(100) | YES | - | City |
| `state` | VARCHAR(50) | YES | - | State code |
| `postal_code` | VARCHAR(20) | YES | - | Postal/zip code |
| `is_active` | BOOLEAN | NO | true | Status toggle |

## Deletion Rules

* **Hard Deletes**: Prohibited by the general `prevent_delete()` trigger.
* **Soft Deletes**: Blocked if there are active assets or open work orders associated with the location:
  * Trigger: `tr_prevent_delete_locations_with_relations`
  * Active Assets Check: Blocked if any assets in the location (via areas) have `deleted_at IS NULL`.
  * Open Work Orders Check: Blocked if any work orders in the location have `status != 'completed'` and `deleted_at IS NULL`.

