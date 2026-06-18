# areas

Internal zones/rooms within a location.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `location_id` | UUID | NO | - | FK → `locations.id` (Cascade) |
| `name` | VARCHAR(255) | NO | - | Zone name (e.g. Sala 102) |
| `floor` | VARCHAR(50) | YES | - | Floor level |
| `description` | VARCHAR(1000) | YES | - | Zone details |
