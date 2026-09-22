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
| `advance_warning_minutes` | INT | NO | 60 | Advance warning minutes before SLA deadline |
| `advance_warning_group_ids` | JSONB | NO | '[]' | Permission groups to notify alongside assigned technician |
| `delayed_notification_interval_minutes` | INT | NO | 60 | Overdue notification repetition interval |
| `escalation_group_ids` | JSONB | NO | '[]' | Cascading escalation hierarchy group IDs |
| `allow_provider_create_work_order` | BOOLEAN | NO | false | Whether service providers may create work orders directly for this company |
| `max_daily_work_orders` | INT | NO | 0 | Max WOs per day. 0 = unlimited |
| `max_attachments_per_work_order` | INT | NO | 0 | Max attachments per WO. 0 = unlimited |
| `max_maintenance_plans` | INT | NO | 0 | Max maintenance plans. 0 = unlimited for paid, disabled when free |
| `max_service_providers` | INT | NO | 0 | Max service providers. 0 = unlimited for paid, disabled when free |
| `max_observations_per_work_order` | INT | NO | 0 | Max observations per WO. 0 = unlimited |

**Note**: `company_id` has a UNIQUE constraint (one row per company).

