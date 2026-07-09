# attachments

Document links and photos captured offline and synchronized online.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `work_order_id` | UUID | NO | - | FK → `work_orders.id` (Cascade) |
| `uploaded_by_id` | UUID | NO | - | FK → `user_profiles.id` (Cascade) |
| `file_name` | VARCHAR(255) | NO | - | Physical name on local storage |
| `file_type` | VARCHAR(50) | NO | - | image / pdf / document / signature |
| `local_path` | VARCHAR(2048) | YES | - | App sandbox local path |
| `remote_url` | VARCHAR(2048) | YES | - | Cloudflare R2 public URL |
| `file_size_bytes` | INT | YES | - | File size |
| `is_compressed` | BOOLEAN | NO | false | Compressed flag (images only) |
| `upload_status` | VARCHAR(50) | NO | 'pending' | pending / uploaded / failed |
| `original_path` | VARCHAR(1000) | YES | - | Path of the file before upload |

**Note**: No `updated_at`.
