-- Create public.audit_logs table
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    parent_entity_type VARCHAR(50),
    parent_entity_id UUID,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    diff JSONB,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON public.audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_parent_entity ON public.audit_logs(parent_entity_type, parent_entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_company ON public.audit_logs(company_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at DESC);

-- Prevent hard delete
CREATE TRIGGER tr_prevent_delete_audit_logs
BEFORE DELETE ON public.audit_logs
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

-- Enable RLS
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
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

-- Migrate existing work_order_history records if the table exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'work_order_history'
    ) THEN
        INSERT INTO public.audit_logs (
            id,
            company_id,
            entity_type,
            entity_id,
            user_id,
            action,
            diff,
            created_at
        )
        SELECT 
            woh.id,
            woh.company_id,
            'work_orders',
            woh.work_order_id,
            woh.user_id,
            woh.action,
            jsonb_build_object(
                'summary', woh.action,
                'changes', jsonb_build_array(
                    jsonb_build_object(
                        'field', 'status',
                        'label', 'Alteração',
                        'old_value', woh.old_value,
                        'new_value', woh.new_value,
                        'old_display', woh.old_value,
                        'new_display', woh.new_value
                    )
                )
            ),
            woh.created_at
        FROM public.work_order_history woh
        ON CONFLICT (id) DO NOTHING;
    END IF;
END $$;

-- -----------------------------------------------------------------------------
-- Generic Audit Trigger Function
-- Automatically detects diffs for all columns (ignoring updated_at) and logs
-- to public.audit_logs. Supports TG_ARGV[0] as parent_entity_type and
-- TG_ARGV[1] as parent_entity_id_column.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_generic_audit()
RETURNS TRIGGER AS $$
DECLARE
    v_old JSONB;
    v_new JSONB;
    v_changes JSONB := '[]'::jsonb;
    v_key TEXT;
    v_company_id UUID;
    v_actor_id UUID := auth.uid();
    v_parent_type VARCHAR(50) := NULL;
    v_parent_id UUID := NULL;
    v_summary TEXT;
    v_is_delete BOOLEAN := false;
    v_is_restore BOOLEAN := false;
BEGIN
    -- Determine parent entity if arguments provided (e.g. TG_ARGV[0] = 'work_orders', TG_ARGV[1] = 'work_order_id')
    IF TG_NARGS >= 1 THEN
        v_parent_type := TG_ARGV[0];
    END IF;

    IF (TG_OP = 'INSERT') THEN
        v_new := to_jsonb(NEW);
        
        -- Resolve company_id (for companies table, NEW.id is the company_id)
        IF TG_TABLE_NAME = 'companies' THEN
            v_company_id := NEW.id;
        ELSE
            v_company_id := NEW.company_id;
        END IF;

        IF TG_NARGS >= 2 AND v_new ? TG_ARGV[1] THEN
            v_parent_id := (v_new ->> TG_ARGV[1])::uuid;
        END IF;

        INSERT INTO public.audit_logs (
            company_id,
            entity_type,
            entity_id,
            parent_entity_type,
            parent_entity_id,
            user_id,
            action,
            diff,
            created_at
        ) VALUES (
            v_company_id,
            TG_TABLE_NAME,
            NEW.id,
            v_parent_type,
            v_parent_id,
            COALESCE(v_actor_id, (v_new ->> 'created_by_id')::uuid, (v_new ->> 'user_id')::uuid),
            'created',
            jsonb_build_object(
                'summary', NULL,
                'changes', '[]'::jsonb
            ),
            COALESCE(NEW.created_at, now())
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        v_old := to_jsonb(OLD);
        v_new := to_jsonb(NEW);

        IF TG_TABLE_NAME = 'companies' THEN
            v_company_id := NEW.id;
        ELSE
            v_company_id := NEW.company_id;
        END IF;

        IF TG_NARGS >= 2 AND v_new ? TG_ARGV[1] THEN
            v_parent_id := (v_new ->> TG_ARGV[1])::uuid;
        END IF;

        -- Check soft delete / restore
        IF (v_old ->> 'deleted_at' IS NULL AND v_new ->> 'deleted_at' IS NOT NULL) THEN
            v_is_delete := true;
        ELSIF (v_old ->> 'deleted_at' IS NOT NULL AND v_new ->> 'deleted_at' IS NULL) THEN
            v_is_restore := true;
        END IF;

        -- Compare all fields except updated_at
        FOR v_key IN 
            SELECT key FROM jsonb_each(v_new)
            WHERE (v_new -> key) IS DISTINCT FROM (v_old -> key)
              AND key NOT IN ('updated_at')
        LOOP
            v_changes := v_changes || jsonb_build_object(
                'field', v_key,
                'label', v_key,
                'old_value', v_old ->> v_key,
                'new_value', v_new ->> v_key,
                'old_display', v_old ->> v_key,
                'new_display', v_new ->> v_key,
                'entity_type', TG_TABLE_NAME,
                'entity_id', NEW.id::text,
                'parent_entity_type', v_parent_type,
                'parent_entity_id', v_parent_id::text
            );
        END LOOP;

        IF jsonb_array_length(v_changes) > 0 THEN
            INSERT INTO public.audit_logs (
                company_id,
                entity_type,
                entity_id,
                parent_entity_type,
                parent_entity_id,
                user_id,
                action,
                diff,
                created_at
            ) VALUES (
                v_company_id,
                TG_TABLE_NAME,
                NEW.id,
                v_parent_type,
                v_parent_id,
                v_actor_id,
                CASE 
                    WHEN v_is_delete THEN 'deleted'
                    WHEN v_is_restore THEN 'restored'
                    ELSE 'updated'
                END,
                jsonb_build_object(
                    'summary', v_summary,
                    'changes', v_changes
                ),
                now()
            );
        END IF;

        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- -----------------------------------------------------------------------------
-- Attach Generic Audit Trigger to Business Tables
-- -----------------------------------------------------------------------------

-- 1. companies
DROP TRIGGER IF EXISTS tr_audit_companies ON public.companies;
CREATE TRIGGER tr_audit_companies
AFTER INSERT OR UPDATE ON public.companies
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 2. company_parameters
DROP TRIGGER IF EXISTS tr_audit_company_parameters ON public.company_parameters;
CREATE TRIGGER tr_audit_company_parameters
AFTER INSERT OR UPDATE ON public.company_parameters
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 3. locations
DROP TRIGGER IF EXISTS tr_audit_locations ON public.locations;
CREATE TRIGGER tr_audit_locations
AFTER INSERT OR UPDATE ON public.locations
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 4. areas (parent = locations, location_id)
DROP TRIGGER IF EXISTS tr_audit_areas ON public.areas;
CREATE TRIGGER tr_audit_areas
AFTER INSERT OR UPDATE ON public.areas
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit('locations', 'location_id');

-- 5. categories
DROP TRIGGER IF EXISTS tr_audit_categories ON public.categories;
CREATE TRIGGER tr_audit_categories
AFTER INSERT OR UPDATE ON public.categories
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 6. assets (parent = areas, area_id)
DROP TRIGGER IF EXISTS tr_audit_assets ON public.assets;
CREATE TRIGGER tr_audit_assets
AFTER INSERT OR UPDATE ON public.assets
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit('areas', 'area_id');

-- 7. checklist_templates
DROP TRIGGER IF EXISTS tr_audit_checklist_templates ON public.checklist_templates;
CREATE TRIGGER tr_audit_checklist_templates
AFTER INSERT OR UPDATE ON public.checklist_templates
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 8. checklist_items (parent = checklist_templates, template_id)
DROP TRIGGER IF EXISTS tr_audit_checklist_items ON public.checklist_items;
CREATE TRIGGER tr_audit_checklist_items
AFTER INSERT OR UPDATE ON public.checklist_items
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit('checklist_templates', 'template_id');

-- 9. maintenance_plans
DROP TRIGGER IF EXISTS tr_audit_maintenance_plans ON public.maintenance_plans;
CREATE TRIGGER tr_audit_maintenance_plans
AFTER INSERT OR UPDATE ON public.maintenance_plans
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 10. work_orders
DROP TRIGGER IF EXISTS tr_audit_work_orders ON public.work_orders;
CREATE TRIGGER tr_audit_work_orders
AFTER INSERT OR UPDATE ON public.work_orders
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 11. tasks (parent = work_orders, work_order_id)
DROP TRIGGER IF EXISTS tr_audit_tasks ON public.tasks;
CREATE TRIGGER tr_audit_tasks
AFTER INSERT OR UPDATE ON public.tasks
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit('work_orders', 'work_order_id');

-- 12. work_order_change_requests (parent = work_orders, work_order_id)
DROP TRIGGER IF EXISTS tr_audit_work_order_change_requests ON public.work_order_change_requests;
CREATE TRIGGER tr_audit_work_order_change_requests
AFTER INSERT OR UPDATE ON public.work_order_change_requests
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit('work_orders', 'work_order_id');

-- 13. user_profiles
DROP TRIGGER IF EXISTS tr_audit_user_profiles ON public.user_profiles;
CREATE TRIGGER tr_audit_user_profiles
AFTER INSERT OR UPDATE ON public.user_profiles
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 14. permission_groups
DROP TRIGGER IF EXISTS tr_audit_permission_groups ON public.permission_groups;
CREATE TRIGGER tr_audit_permission_groups
AFTER INSERT OR UPDATE ON public.permission_groups
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 15. sla_policies
DROP TRIGGER IF EXISTS tr_audit_sla_policies ON public.sla_policies;
CREATE TRIGGER tr_audit_sla_policies
AFTER INSERT OR UPDATE ON public.sla_policies
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 16. sectors
DROP TRIGGER IF EXISTS tr_audit_sectors ON public.sectors;
CREATE TRIGGER tr_audit_sectors
AFTER INSERT OR UPDATE ON public.sectors
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 17. pause_reasons
DROP TRIGGER IF EXISTS tr_audit_pause_reasons ON public.pause_reasons;
CREATE TRIGGER tr_audit_pause_reasons
AFTER INSERT OR UPDATE ON public.pause_reasons
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 18. service_provider_companies
DROP TRIGGER IF EXISTS tr_audit_service_provider_companies ON public.service_provider_companies;
CREATE TRIGGER tr_audit_service_provider_companies
AFTER INSERT OR UPDATE ON public.service_provider_companies
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- 19. service_provider_profiles (parent = service_provider_companies, service_provider_company_id)
DROP TRIGGER IF EXISTS tr_audit_service_provider_profiles ON public.service_provider_profiles;
CREATE TRIGGER tr_audit_service_provider_profiles
AFTER INSERT OR UPDATE ON public.service_provider_profiles
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit('service_provider_companies', 'service_provider_company_id');

-- 20. work_order_observations (parent = work_orders, work_order_id)
DROP TRIGGER IF EXISTS tr_audit_work_order_observations ON public.work_order_observations;
CREATE TRIGGER tr_audit_work_order_observations
AFTER INSERT OR UPDATE ON public.work_order_observations
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit('work_orders', 'work_order_id');

-- -----------------------------------------------------------------------------
-- Specialized Triggers with Custom Metadata/Diff
-- -----------------------------------------------------------------------------

-- Attachments (needs file metadata preservation)
CREATE OR REPLACE FUNCTION public.handle_audit_attachments()
RETURNS TRIGGER AS $$
DECLARE
    v_actor_id UUID := auth.uid();
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO public.audit_logs (
            company_id,
            entity_type,
            entity_id,
            parent_entity_type,
            parent_entity_id,
            user_id,
            action,
            diff,
            metadata,
            created_at
        ) VALUES (
            NEW.company_id,
            'attachments',
            NEW.id,
            'work_orders',
            NEW.work_order_id,
            COALESCE(NEW.uploaded_by_id, v_actor_id),
            'created',
            jsonb_build_object(
                'summary', 'Anexo adicionado: ' || COALESCE(NEW.file_name, 'arquivo'),
                'changes', '[]'::jsonb
            ),
            jsonb_build_object(
                'file_name', NEW.file_name,
                'file_url', COALESCE(NEW.remote_url, NEW.local_path),
                'file_type', NEW.file_type,
                'file_size_bytes', NEW.file_size_bytes
            ),
            COALESCE(NEW.created_at, now())
        );
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL) THEN
            INSERT INTO public.audit_logs (
                company_id,
                entity_type,
                entity_id,
                parent_entity_type,
                parent_entity_id,
                user_id,
                action,
                diff,
                metadata,
                created_at
            ) VALUES (
                NEW.company_id,
                'attachments',
                NEW.id,
                'work_orders',
                NEW.work_order_id,
                v_actor_id,
                'deleted',
                jsonb_build_object(
                    'summary', 'Anexo removido: ' || COALESCE(NEW.file_name, 'arquivo'),
                    'changes', jsonb_build_array(
                        jsonb_build_object(
                            'field', 'deleted_at',
                            'label', 'Remoção',
                            'old_value', NULL,
                            'new_value', NEW.deleted_at::text,
                            'old_display', 'Ativo',
                            'new_display', 'Removido',
                            'entity_type', 'attachments',
                            'entity_id', NEW.id::text,
                            'parent_entity_type', 'work_orders',
                            'parent_entity_id', NEW.work_order_id::text
                        )
                    )
                ),
                jsonb_build_object(
                    'file_name', NEW.file_name,
                    'file_url', COALESCE(NEW.remote_url, NEW.local_path),
                    'file_type', NEW.file_type,
                    'file_size_bytes', NEW.file_size_bytes
                ),
                now()
            );
        END IF;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_audit_attachments ON public.attachments;
CREATE TRIGGER tr_audit_attachments
AFTER INSERT OR UPDATE ON public.attachments
FOR EACH ROW
EXECUTE FUNCTION public.handle_audit_attachments();

-- Pause requests (needs lifecycle status diff + request metadata)
CREATE OR REPLACE FUNCTION public.handle_audit_pause_requests()
RETURNS TRIGGER AS $$
DECLARE
    v_actor_id UUID := auth.uid();
    v_event_label TEXT;
    v_summary TEXT;
BEGIN
    v_event_label := CASE WHEN NEW.event_type = 'completion' THEN 'Conclusão' ELSE 'Pausa' END;

    IF (TG_OP = 'INSERT') THEN
        v_summary := 'Solicitação de ' || lower(v_event_label) || ' enviada: ' || COALESCE(NEW.reason, '');
        INSERT INTO public.audit_logs (
            company_id,
            entity_type,
            entity_id,
            parent_entity_type,
            parent_entity_id,
            user_id,
            action,
            diff,
            metadata,
            created_at
        ) VALUES (
            NEW.company_id,
            'work_order_pause_requests',
            NEW.id,
            'work_orders',
            NEW.work_order_id,
            COALESCE(NEW.requested_by_id, v_actor_id),
            'created',
            jsonb_build_object(
                'summary', v_summary,
                'changes', '[]'::jsonb
            ),
            jsonb_build_object(
                'event_type', NEW.event_type,
                'reason', NEW.reason,
                'status', NEW.status
            ),
            COALESCE(NEW.created_at, now())
        );
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (OLD.status IS DISTINCT FROM NEW.status) THEN
            v_summary := 'Solicitação de ' || lower(v_event_label) || ' ' || 
                CASE NEW.status
                    WHEN 'approved' THEN 'aprovada'
                    WHEN 'rejected' THEN 'rejeitada'
                    WHEN 'cancelled_by_provider' THEN 'cancelada pelo prestador'
                    WHEN 'cancelled' THEN 'cancelada'
                    ELSE NEW.status
                END;

            INSERT INTO public.audit_logs (
                company_id,
                entity_type,
                entity_id,
                parent_entity_type,
                parent_entity_id,
                user_id,
                action,
                diff,
                metadata,
                created_at
            ) VALUES (
                NEW.company_id,
                'work_order_pause_requests',
                NEW.id,
                'work_orders',
                NEW.work_order_id,
                COALESCE(NEW.reviewed_by_id, v_actor_id),
                'status_changed',
                jsonb_build_object(
                    'summary', v_summary,
                    'changes', jsonb_build_array(
                        jsonb_build_object(
                            'field', 'status',
                            'label', 'Status da Solicitação',
                            'old_value', OLD.status,
                            'new_value', NEW.status,
                            'old_display', OLD.status,
                            'new_display', NEW.status,
                            'entity_type', 'work_order_pause_requests',
                            'entity_id', NEW.id::text,
                            'parent_entity_type', 'work_orders',
                            'parent_entity_id', NEW.work_order_id::text
                        )
                    )
                ),
                jsonb_build_object(
                    'event_type', NEW.event_type,
                    'reason', NEW.reason,
                    'status', NEW.status,
                    'review_observation', NEW.review_observation
                ),
                now()
            );
        END IF;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_audit_pause_requests ON public.work_order_pause_requests;
CREATE TRIGGER tr_audit_pause_requests
AFTER INSERT OR UPDATE ON public.work_order_pause_requests
FOR EACH ROW
EXECUTE FUNCTION public.handle_audit_pause_requests();

