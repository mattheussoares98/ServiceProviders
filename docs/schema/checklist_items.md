# checklist_items

Specific items/checks linked to a checklist_template.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `template_id` | UUID | NO | - | FK → `checklist_templates.id` (Cascade) |
| `label` | VARCHAR(500) | NO | - | Inspection question/instruction |
| `type` | VARCHAR(50) | NO | 'boolean' | boolean / text / number / photo / selection |
| `is_required` | BOOLEAN | NO | false | Required toggle |
| `options` | JSONB | YES | - | Options for 'selection' types |
| `sort_order` | INT | NO | 0 | Positional sort index |

**Note**: No `updated_at`.
