# Resolved Questions

| # | Question | Decision |
|---|---|---|
| Q1 | App Name | "ServicePro" (working title) |
| Q2 | Multi-Company | ❌ Not in V1. Maybe V3 |
| Q3 | Phase Priority | Phase 0 (cleanup Isar → Drift) comes first, then offline-first, then Supabase |
| Q4 | Company Creation | Manual process — customer contacts admin to negotiate and create |
| Q5 | Platforms | User handles platform configuration |
| Q6 | Notifications | Firebase FCM, only after V2 is running |
| Q7 | Local DB | Drift (single SQLite database). Isar is abandoned — do NOT use |
| Q8 | Offline scope | Edits to work orders are allowed. If edited/closed by someone else, subsequent sync requests are automatically redirected to `WorkOrderChangeRequest` by database triggers to avoid conflicts. |
| Q9 | Localization | `.hardcoded` extension on all strings for future i18n |
| Q10 | File compression | `image_compress_plus`, quality 75-80, max 1920px |
| Q11 | DB documentation | Already enforced in `database.md` agent rule → `docs/schema/` |
| Q12 | Permission groups | 3 default groups (Admin, Gestor, Técnico) + custom per company |
| Q13 | revisionForecast | Added to Asset entity for proactive notifications |
| Q14 | Handling Closed Orders | Edits to completed/cancelled orders are saved as change requests in a queue rather than direct updates or requiring pre-approval reopening (to support offline-first). Intercepted automatically by database triggers. |
| Q15 | Stopwatch Workflow | Added stopwatch-style (play/pause/stop) time tracking for technicians. `actualDuration` is calculated automatically from timestamps, and all transitions are logged as immutable audit events in `work_order_history` to ensure accountability. |

