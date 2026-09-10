-- Migration: Exclude technical escalation tracking columns from audit_logs and clean up existing logs

-- 1. Update handle_generic_audit to exclude escalation tracking columns
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

        -- Compare all fields except updated_at and technical escalation tracking columns
        FOR v_key IN 
            SELECT key FROM jsonb_each(v_new)
            WHERE (v_new -> key) IS DISTINCT FROM (v_old -> key)
              AND key NOT IN ('updated_at', 'advance_warning_sent_at', 'last_escalation_at', 'last_escalation_level')
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

-- 2. Cleanup existing audit logs that contain escalation tracking fields
DO $$
DECLARE
    r RECORD;
    v_change JSONB;
    v_new_changes JSONB;
    v_field TEXT;
    i INT;
BEGIN
    ALTER TABLE public.audit_logs DISABLE TRIGGER tr_prevent_delete_audit_logs;

    FOR r IN 
        SELECT id, diff 
        FROM public.audit_logs 
        WHERE diff ? 'changes' 
          AND (
            diff::text LIKE '%advance_warning_sent_at%' 
            OR diff::text LIKE '%last_escalation_at%' 
            OR diff::text LIKE '%last_escalation_level%'
          )
    LOOP
        v_new_changes := '[]'::jsonb;
        FOR i IN 0 .. jsonb_array_length(r.diff->'changes') - 1 LOOP
            v_change := r.diff->'changes'->i;
            v_field := v_change->>'field';
            
            IF v_field NOT IN ('advance_warning_sent_at', 'last_escalation_at', 'last_escalation_level') THEN
                v_new_changes := v_new_changes || jsonb_build_array(v_change);
            END IF;
        END LOOP;

        IF jsonb_array_length(v_new_changes) = 0 THEN
            DELETE FROM public.audit_logs WHERE id = r.id;
        ELSE
            UPDATE public.audit_logs
            SET diff = jsonb_set(diff, '{changes}', v_new_changes)
            WHERE id = r.id;
        END IF;
    END LOOP;

    ALTER TABLE public.audit_logs ENABLE TRIGGER tr_prevent_delete_audit_logs;
END;
$$;
