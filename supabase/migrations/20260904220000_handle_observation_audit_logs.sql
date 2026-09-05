-- =============================================================================
-- Migration: Specialized Audit Trigger for work_order_observations
-- Logs created observations with new_value and deleted observations with old_value.
-- Backfills existing observation audit logs.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_audit_work_order_observations()
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
            created_at
        ) VALUES (
            NEW.company_id,
            'work_order_observations',
            NEW.id,
            'work_orders',
            NEW.work_order_id,
            COALESCE(NEW.author_id, NEW.author_provider_profile_id, v_actor_id),
            'created',
            jsonb_build_object(
                'summary', 'Observação adicionada',
                'changes', jsonb_build_array(
                    jsonb_build_object(
                        'field', 'content',
                        'label', 'Observação',
                        'old_value', NULL,
                        'new_value', NEW.content,
                        'old_display', NULL,
                        'new_display', NEW.content,
                        'entity_type', 'work_order_observations',
                        'entity_id', NEW.id::text,
                        'parent_entity_type', 'work_orders',
                        'parent_entity_id', NEW.work_order_id::text
                    )
                )
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
                created_at
            ) VALUES (
                NEW.company_id,
                'work_order_observations',
                NEW.id,
                'work_orders',
                NEW.work_order_id,
                v_actor_id,
                'deleted',
                jsonb_build_object(
                    'summary', 'Observação removida',
                    'changes', jsonb_build_array(
                        jsonb_build_object(
                            'field', 'content',
                            'label', 'Observação',
                            'old_value', OLD.content,
                            'new_value', NULL,
                            'old_display', OLD.content,
                            'new_display', NULL,
                            'entity_type', 'work_order_observations',
                            'entity_id', NEW.id::text,
                            'parent_entity_type', 'work_orders',
                            'parent_entity_id', NEW.work_order_id::text
                        )
                    )
                ),
                now()
            );
        END IF;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate trigger on work_order_observations
DROP TRIGGER IF EXISTS tr_audit_work_order_observations ON public.work_order_observations;
CREATE TRIGGER tr_audit_work_order_observations
AFTER INSERT OR UPDATE ON public.work_order_observations
FOR EACH ROW
EXECUTE FUNCTION public.handle_audit_work_order_observations();

-- Backfill created observation logs
UPDATE public.audit_logs al
SET diff = jsonb_build_object(
    'summary', 'Observação adicionada',
    'changes', jsonb_build_array(
        jsonb_build_object(
            'field', 'content',
            'label', 'Observação',
            'old_value', NULL,
            'new_value', woo.content,
            'old_display', NULL,
            'new_display', woo.content,
            'entity_type', 'work_order_observations',
            'entity_id', woo.id::text,
            'parent_entity_type', 'work_orders',
            'parent_entity_id', woo.work_order_id::text
        )
    )
)
FROM public.work_order_observations woo
WHERE al.entity_type = 'work_order_observations'
  AND al.entity_id = woo.id
  AND al.action = 'created';

-- Backfill deleted observation logs
UPDATE public.audit_logs al
SET diff = jsonb_build_object(
    'summary', 'Observação removida',
    'changes', jsonb_build_array(
        jsonb_build_object(
            'field', 'content',
            'label', 'Observação',
            'old_value', woo.content,
            'new_value', NULL,
            'old_display', woo.content,
            'new_display', NULL,
            'entity_type', 'work_order_observations',
            'entity_id', woo.id::text,
            'parent_entity_type', 'work_orders',
            'parent_entity_id', woo.work_order_id::text
        )
    )
)
FROM public.work_order_observations woo
WHERE al.entity_type = 'work_order_observations'
  AND al.entity_id = woo.id
  AND al.action = 'deleted';
