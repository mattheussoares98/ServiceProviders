-- Migration: 20260925235500_fix_handle_generic_audit_user_id.sql
-- Description: Ensure handle_generic_audit only writes user_id if the user exists in public.user_profiles, preventing foreign key violations during onboarding.

CREATE OR REPLACE FUNCTION public.handle_generic_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_old JSONB;
    v_new JSONB;
    v_changes JSONB := '[]'::jsonb;
    v_key TEXT;
    v_company_id UUID;
    v_raw_actor_id UUID := auth.uid();
    v_actor_id UUID := NULL;
    v_parent_type VARCHAR(50) := NULL;
    v_parent_id UUID := NULL;
    v_summary TEXT;
    v_is_delete BOOLEAN := false;
    v_is_restore BOOLEAN := false;
    v_old_val TEXT;
    v_new_val TEXT;
    v_old_disp TEXT;
    v_new_disp TEXT;
    v_candidate_user_id UUID;
BEGIN
    -- Determine parent entity if arguments provided (e.g. TG_ARGV[0] = 'work_orders', TG_ARGV[1] = 'work_order_id')
    IF TG_NARGS >= 1 THEN
        v_parent_type := TG_ARGV[0];
    END IF;

    IF (TG_OP = 'INSERT') THEN
        v_new := to_jsonb(NEW);
        
        -- Resolve company_id
        IF TG_TABLE_NAME = 'companies' THEN
            v_company_id := NEW.id;
        ELSIF TG_TABLE_NAME = 'service_provider_profiles' THEN
            SELECT company_id INTO v_company_id FROM public.service_provider_companies WHERE id = NEW.service_provider_company_id;
        ELSE
            IF v_new ? 'company_id' THEN
                v_company_id := (v_new ->> 'company_id')::uuid;
            END IF;
        END IF;

        IF TG_NARGS >= 2 AND v_new ? TG_ARGV[1] THEN
            v_parent_id := (v_new ->> TG_ARGV[1])::uuid;
        END IF;

        v_candidate_user_id := COALESCE(v_raw_actor_id, (v_new ->> 'created_by_id')::uuid, (v_new ->> 'user_id')::uuid);
        IF v_candidate_user_id IS NOT NULL THEN
            SELECT id INTO v_actor_id FROM public.user_profiles WHERE id = v_candidate_user_id;
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
            v_actor_id,
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
        ELSIF TG_TABLE_NAME = 'service_provider_profiles' THEN
            SELECT company_id INTO v_company_id FROM public.service_provider_companies WHERE id = NEW.service_provider_company_id;
        ELSE
            IF v_new ? 'company_id' THEN
                v_company_id := (v_new ->> 'company_id')::uuid;
            END IF;
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
            IF v_raw_actor_id IS NOT NULL THEN
                SELECT id INTO v_actor_id FROM public.user_profiles WHERE id = v_raw_actor_id;
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
$function$;
