# audit_logs — Database Rules

## 1. RLS Policies

```sql
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view audit logs of their company or provider work orders"
    ON public.audit_logs
    FOR SELECT
    TO authenticated
    USING (
        company_id = public.get_user_company_id()
        OR (
            entity_type = 'work_orders'
            AND public.is_provider_member_of_work_order_id(entity_id)
        )
        OR (
            parent_entity_type = 'work_orders'
            AND parent_entity_id IS NOT NULL
            AND public.is_provider_member_of_work_order_id(parent_entity_id)
        )
    );

CREATE POLICY "Users can insert audit logs for their company or provider work orders"
    ON public.audit_logs
    FOR INSERT
    TO authenticated
    WITH CHECK (
        company_id = public.get_user_company_id()
        OR (
            entity_type = 'work_orders'
            AND public.is_provider_member_of_work_order_id(entity_id)
        )
        OR (
            parent_entity_type = 'work_orders'
            AND parent_entity_id IS NOT NULL
            AND public.is_provider_member_of_work_order_id(parent_entity_id)
        )
    );
```

## 2. Triggers

### 2.1 Hard Delete Protection
```sql
CREATE TRIGGER tr_prevent_delete_audit_logs
BEFORE DELETE ON public.audit_logs
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();
```

### 2.2 Automated Entity Auditing Triggers

Auditing is managed via **`public.handle_generic_audit()`** which dynamically inspects all changed columns (ignoring technical timestamp `updated_at`), records old/new values, and assigns entity/parent IDs.

#### Tracked Tables (Audited)
Every table modifiable by users or business operations is attached to `handle_generic_audit()` (or specialized handlers where attachment/pause metadata is preserved):
- **Core Entities**: `companies`, `company_parameters`, `locations`, `categories`, `checklist_templates`, `maintenance_plans`, `work_orders`, `user_profiles`, `permission_groups`, `sla_policies`, `sectors`, `pause_reasons`, `service_provider_companies`.
- **Child Entities** (with parent tracking):
  - `areas` (parent: `locations`)
  - `assets` (parent: `areas`)
  - `checklist_items` (parent: `checklist_templates`)
  - `tasks` (parent: `work_orders`)
  - `work_order_change_requests` (parent: `work_orders`)
  - `work_order_observations` (parent: `work_orders`)
  - `service_provider_profiles` (parent: `service_provider_companies`)
  - `attachments` (specialized handler: preserves `file_name`, `file_url`, `file_type`, `file_size_bytes`)
  - `work_order_pause_requests` (specialized handler: preserves `event_type`, `reason`, `review_observation`)

#### Excluded Tables (Never Audited)
To prevent infinite recursion, high-throughput churn, or logging transient device state, these tables **must never** have an audit trigger:
- `audit_logs` (self-referential loop prevention)
- `sync_audit_logs` (pure telemetry/sync queue logging)
- `sync_errors` (ephemeral sync diagnostic logs)
- `user_device_tokens` (high-frequency FCM token updates on app launch)
- `user_parameters`, `user_configurations` (ephemeral/local device UI preferences)
