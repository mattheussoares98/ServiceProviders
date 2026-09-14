-- ==============================================================================
-- Notify Managers & Supervisors on Work Order Status change to 'pending_conclusion'
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_notify_work_order_pending_conclusion()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_manager_ids UUID[];
  v_title TEXT;
  v_body TEXT;
BEGIN
  -- Trigger when status transitions to 'pending_conclusion'
  IF (TG_OP = 'INSERT' AND NEW.status = 'pending_conclusion') OR
     (TG_OP = 'UPDATE' AND NEW.status = 'pending_conclusion' AND (OLD.status IS DISTINCT FROM 'pending_conclusion')) THEN

    -- Resolve users in the same company with manage_pending_requests permission or admin
    SELECT ARRAY_AGG(up.id)
    INTO v_manager_ids
    FROM public.user_profiles up
    LEFT JOIN public.permission_groups pg ON up.permission_group_id = pg.id
    WHERE up.company_id = NEW.company_id
      AND up.is_active = true
      AND up.deleted_at IS NULL
      AND (
        COALESCE(up.is_admin, false) = true
        OR COALESCE(pg.permissions, '{}'::jsonb) ? '*'
        OR COALESCE((pg.permissions -> '*') = 'true'::jsonb, false)
        OR COALESCE(pg.permissions, '{}'::jsonb) ? 'work_orders.manage_pending_requests'
        OR COALESCE((pg.permissions -> 'work_orders.manage_pending_requests') = 'true'::jsonb, false)
      );

    IF v_manager_ids IS NOT NULL AND array_length(v_manager_ids, 1) > 0 THEN
      v_title := 'Conclusão pendente de aprovação';
      v_body := 'Ordem #' || NEW.number || ' - ' || NEW.title || ' aguarda sua revisão.';

      PERFORM public.dispatch_push_notification(
        v_manager_ids,
        v_title,
        v_body,
        jsonb_build_object(
          'type', 'work_order_pending_conclusion',
          'work_order_id', NEW.id::text,
          'company_id', NEW.company_id::text
        )
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_notify_work_order_pending_conclusion ON public.work_orders;
CREATE TRIGGER tr_notify_work_order_pending_conclusion
  AFTER INSERT OR UPDATE OF status ON public.work_orders
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_notify_work_order_pending_conclusion();
