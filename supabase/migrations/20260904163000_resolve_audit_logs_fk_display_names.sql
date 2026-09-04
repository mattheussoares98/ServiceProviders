-- =============================================================================
-- Migration: Enhance handle_generic_audit to resolve FK display names
-- Resolves names for location_id, area_id, asset_id, category_id,
-- assigned_to_id, created_by_id, requested_by_id, reviewed_by_id,
-- service_provider_company_id, sla_policy_id, sector_id, pause_reason_id, template_id
-- =============================================================================

CREATE OR REPLACE FUNCTION public.resolve_audit_display_value(
    p_field TEXT,
    p_raw_value TEXT
)
RETURNS TEXT AS $$
DECLARE
    v_uuid UUID;
    v_name TEXT;
BEGIN
    IF p_raw_value IS NULL OR trim(p_raw_value) = '' THEN
        RETURN p_raw_value;
    END IF;

    -- Validate UUID format
    BEGIN
        v_uuid := p_raw_value::uuid;
    EXCEPTION WHEN OTHERS THEN
        RETURN p_raw_value;
    END;

    CASE p_field
        WHEN 'location_id' THEN
            SELECT name INTO v_name FROM public.locations WHERE id = v_uuid;
        WHEN 'area_id' THEN
            SELECT name INTO v_name FROM public.areas WHERE id = v_uuid;
        WHEN 'asset_id' THEN
            SELECT name INTO v_name FROM public.assets WHERE id = v_uuid;
        WHEN 'category_id' THEN
            SELECT name INTO v_name FROM public.categories WHERE id = v_uuid;
        WHEN 'assigned_to_id', 'created_by_id', 'requested_by_id', 'reviewed_by_id', 'user_id', 'user_profile_id', 'uploaded_by_id', 'completed_by_id' THEN
            SELECT name INTO v_name FROM public.user_profiles WHERE id = v_uuid;
        WHEN 'service_provider_company_id' THEN
            SELECT trade_name INTO v_name FROM public.service_provider_companies WHERE id = v_uuid;
            IF v_name IS NULL THEN
                SELECT legal_name INTO v_name FROM public.service_provider_companies WHERE id = v_uuid;
            END IF;
        WHEN 'provider_profile_id' THEN
            SELECT name INTO v_name FROM public.service_provider_profiles WHERE id = v_uuid;
        WHEN 'sla_policy_id' THEN
            SELECT name INTO v_name FROM public.sla_policies WHERE id = v_uuid;
        WHEN 'sector_id' THEN
            SELECT name INTO v_name FROM public.sectors WHERE id = v_uuid;
        WHEN 'pause_reason_id' THEN
            SELECT name INTO v_name FROM public.pause_reasons WHERE id = v_uuid;
        WHEN 'template_id' THEN
            SELECT name INTO v_name FROM public.checklist_templates WHERE id = v_uuid;
        WHEN 'maintenance_plan_id' THEN
            SELECT title INTO v_name FROM public.maintenance_plans WHERE id = v_uuid;
        ELSE
            v_name := NULL;
    END CASE;

    RETURN COALESCE(v_name, p_raw_value);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

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
    v_old_val TEXT;
    v_new_val TEXT;
    v_old_disp TEXT;
    v_new_disp TEXT;
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
            v_old_val := v_old ->> v_key;
            v_new_val := v_new ->> v_key;
            v_old_disp := public.resolve_audit_display_value(v_key, v_old_val);
            v_new_disp := public.resolve_audit_display_value(v_key, v_new_val);

            v_changes := v_changes || jsonb_build_object(
                'field', v_key,
                'label', v_key,
                'old_value', v_old_val,
                'new_value', v_new_val,
                'old_display', v_old_disp,
                'new_display', v_new_disp,
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
