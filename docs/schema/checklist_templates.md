# checklist_templates

Pre-configured checklists for inspections.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(255) | NO | - | Template name |
| `description` | VARCHAR(1000) | YES | - | Inspection details |
| `category_id` | UUID | YES | - | FK → `categories.id` (Set Null) |
