# checklist_answers

Execution answers for a checklist item on a specific work order. One row per
`(work_order_id, checklist_item_id)` pair.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `work_order_id` | UUID | NO | - | FK → `work_orders.id` (Cascade) |
| `checklist_item_id` | UUID | NO | - | FK → `checklist_items.id` (Cascade) |
| `boolean_value` | BOOLEAN | YES | - | Answer for `boolean` items |
| `text_value` | VARCHAR(2000) | YES | - | Answer for `text` items |
| `number_value` | NUMERIC | YES | - | Answer for `number` items |
| `photo_url` | VARCHAR(2000) | YES | - | Answer for `photo` / `documentation` items |
| `selected_option` | VARCHAR(500) | YES | - | Answer for `selection` items |

**Notes**
- `company_id` defaults to `public.get_user_company_id()`; the client does not send it.
- Unique index `idx_checklist_answers_unique_item` on `(work_order_id, checklist_item_id)` —
  `saveResponse` upserts on that pair.
