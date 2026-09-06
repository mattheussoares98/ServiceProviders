-- ==============================================================================
-- Fix handle_audit_pause_requests: replace non-existent NEW.reason with NEW.custom_reason
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_audit_pause_requests()
RETURNS TRIGGER AS $$
DECLARE
    v_actor_id UUID := auth.uid();
    v_event_label TEXT;
    v_summary TEXT;
BEGIN
    v_event_label := CASE WHEN NEW.event_type = 'completion' THEN 'Conclusão' ELSE 'Pausa' END;

    IF (TG_OP = 'INSERT') THEN
        v_summary := 'Solicitação de ' || lower(v_event_label) || ' enviada: ' || COALESCE(NEW.custom_reason, '');
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
                'reason_id', NEW.reason_id,
                'custom_reason', NEW.custom_reason,
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
                    'reason_id', NEW.reason_id,
                    'custom_reason', NEW.custom_reason,
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
