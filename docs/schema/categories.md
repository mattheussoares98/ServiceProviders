# categories

Equipment categories to organize assets.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(100) | NO | - | Category label (Unique per company and case-insensitive when active) |
| `description` | VARCHAR(500) | YES | - | Category details |
| `color` | VARCHAR(50) | YES | - | UI tag color code |

**Note**: No `updated_at`.

## Deletion Rules

* **Hard Deletes**: Prohibited by the general `prevent_delete()` trigger.
* **Soft Deletes**: Blocked if there are active assets associated with the category:
  * Trigger: `tr_prevent_delete_categories_with_relations`
  * Active Assets Check: Blocked if any asset referencing this category has `deleted_at IS NULL`.

