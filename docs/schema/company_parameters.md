# company_parameters

Configuration limits governing client offline allowances.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `max_offline_duration_hours` | INT | NO | 2 | Alert limit: hours offline |
| `max_offline_pending_requests` | INT | NO | 10 | Alert limit: pending queue size |

**Note**: `company_id` has a UNIQUE constraint (one row per company).
