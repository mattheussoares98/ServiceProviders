# pause_reasons

Stores the pre-registered pause justifications defined per company.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(100) | NO | - | Pre-registered reason text (e.g. 'Aguardando material') |
| `is_active` | BOOLEAN | NO | true | Whether this reason is active and selectable |
