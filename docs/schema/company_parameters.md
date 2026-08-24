# company_parameters

Configuration limits governing client offline allowances, file upload thresholds, cache quotas, and system governance.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `max_offline_duration_hours` | INT | NO | 2 | Alert limit: hours offline |
| `max_offline_pending_requests` | INT | NO | 10 | Alert limit: pending queue size |
| `offline_alert_throttle_frequency` | INT | NO | 3 | Mutation count interval between repeated alerts |
| `max_image_size_mb` | INT | NO | 20 | Maximum original image upload size (MB) |
| `max_video_size_mb` | INT | NO | 500 | Maximum original video upload size (MB) |
| `max_pdf_size_mb` | INT | NO | 10 | Maximum PDF upload size (MB) |
| `max_document_size_mb` | INT | NO | 5 | Maximum document (docx/xlsx) upload size (MB) |
| `sandbox_quota_mb` | INT | NO | 1024 | Attachment sandbox cache quota (MB) |
| `max_sync_attempts` | INT | NO | 3 | Maximum sync queue retry attempts |
| `invite_expiry_hours` | INT | NO | 24 | User invitation expiry duration in hours |

**Note**: `company_id` has a UNIQUE constraint (one row per company).
