# locations

Facilities/sites managed by a company.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(255) | NO | - | Facility name (Unique per company) |
| `address` | VARCHAR(500) | YES | - | Street name |
| `number` | VARCHAR(20) | YES | - | Street/building number |
| `complement` | VARCHAR(255) | YES | - | Address complement |
| `neighborhood` | VARCHAR(100) | YES | - | Neighborhood |
| `city` | VARCHAR(100) | YES | - | City |
| `state` | VARCHAR(50) | YES | - | State code |
| `postal_code` | VARCHAR(20) | YES | - | Postal/zip code |
| `is_active` | BOOLEAN | NO | true | Status toggle |
