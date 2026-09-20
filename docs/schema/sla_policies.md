# sla_policies

Defines Service Level Agreements (SLAs) with target response or resolution times.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(100) | NO | - | Name of the SLA policy (e.g. 'Emergency', 'Standard') |
| `target_hours` | INT | NO | - | Limit in hours to complete the work order |
| `applies_to` | VARCHAR(20) | NO | 'both' | Target audience: `provider` / `contractor` / `both` |

## Constraints

* `chk_sla_policies_name_not_empty`: `CHECK (length(trim(name)) > 0)` prevents empty or whitespace-only names.
* `chk_sla_policies_target_hours_positive`: `CHECK (target_hours > 0)` ensures target duration is strictly positive.
* `chk_applies_to`: `CHECK (applies_to IN ('provider', 'contractor', 'both'))` restricts allowed audience values.
