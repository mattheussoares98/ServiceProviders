-- =============================================================================
-- Migration: Improve FK display name resolution (including providers) and backfill existing audit logs
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
        WHEN 'assigned_to_id', 'created_by_id', 'requested_by_id', 'reviewed_by_id', 'user_id', 'user_profile_id', 'uploaded_by_id', 'completed_by_id', 'resumed_by_id' THEN
            SELECT name INTO v_name FROM public.user_profiles WHERE id = v_uuid;
        WHEN 'service_provider_company_id' THEN
            SELECT name INTO v_name FROM public.service_provider_companies WHERE id = v_uuid;
        WHEN 'provider_profile_id', 'created_by_provider_profile_id' THEN
            SELECT COALESCE(up.name, NULLIF(spp.name, spp.email), spp.name, spp.email)
            INTO v_name
            FROM public.service_provider_profiles spp
            LEFT JOIN public.user_profiles up ON up.id = spp.auth_user_id
            WHERE spp.id = v_uuid;
        WHEN 'sla_policy_id' THEN
            SELECT name INTO v_name FROM public.sla_policies WHERE id = v_uuid;
        WHEN 'sector_id', 'completion_sector_id' THEN
            SELECT name INTO v_name FROM public.sectors WHERE id = v_uuid;
        WHEN 'pause_reason_id' THEN
            SELECT name INTO v_name FROM public.pause_reasons WHERE id = v_uuid;
        WHEN 'template_id', 'checklist_template_id' THEN
            SELECT name INTO v_name FROM public.checklist_templates WHERE id = v_uuid;
        WHEN 'maintenance_plan_id' THEN
            SELECT title INTO v_name FROM public.maintenance_plans WHERE id = v_uuid;
        ELSE
            v_name := NULL;
    END CASE;

    RETURN COALESCE(v_name, p_raw_value);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Backfill existing audit logs diffs with resolved display values
DO $$
DECLARE
    r RECORD;
    v_new_changes JSONB;
    v_change JSONB;
    v_field TEXT;
    v_old_val TEXT;
    v_new_val TEXT;
    v_old_disp TEXT;
    v_new_disp TEXT;
    i INT;
BEGIN
    FOR r IN 
        SELECT id, diff 
        FROM public.audit_logs 
        WHERE diff ? 'changes' AND jsonb_array_length(diff->'changes') > 0 
    LOOP
        v_new_changes := '[]'::jsonb;
        FOR i IN 0 .. jsonb_array_length(r.diff->'changes') - 1 LOOP
            v_change := r.diff->'changes'->i;
            v_field := v_change->>'field';
            v_old_val := v_change->>'old_value';
            v_new_val := v_change->>'new_value';
            
            v_old_disp := public.resolve_audit_display_value(v_field, v_old_val);
            v_new_disp := public.resolve_audit_display_value(v_field, v_new_val);

            v_change := jsonb_set(v_change, '{old_display}', to_jsonb(v_old_disp));
            v_change := jsonb_set(v_change, '{new_display}', to_jsonb(v_new_disp));
            
            v_new_changes := v_new_changes || jsonb_build_array(v_change);
        END LOOP;

        UPDATE public.audit_logs
        SET diff = jsonb_set(diff, '{changes}', v_new_changes)
        WHERE id = r.id;
    END LOOP;
END;
$$;
