# sla_policies

Defines Service Level Agreements (SLAs) with target response or resolution times.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(100) | NO | - | Name of the SLA policy (e.g. 'Emergency', 'Standard') |
| `target_hours` | INT | NO | - | Limit in hours to complete the work order |
| `applies_to` | VARCHAR(20) | NO | 'both' | Target audience: `provider` / `contractor` / `both` |
