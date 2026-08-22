-- ========================================================
-- Push Notification Helper and Automatic Triggers
-- ========================================================

-- 1. Helper function to invoke Edge Function or dispatch notification
CREATE OR REPLACE FUNCTION public.dispatch_push_notification(
  p_user_ids UUID[],
  p_title TEXT,
  p_body TEXT,
  p_data JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_filtered_ids UUID[];
  v_payload JSONB;
BEGIN
  IF p_user_ids IS NULL OR array_length(p_user_ids, 1) IS NULL THEN
    RETURN;
  END IF;

  -- Remove nulls and duplicates, and filter out the current acting user
  SELECT ARRAY_AGG(DISTINCT uid)
  INTO v_filtered_ids
  FROM UNNEST(p_user_ids) AS uid
  WHERE uid IS NOT NULL
    AND uid != COALESCE(auth.uid(), '00000000-0000-0000-0000-000000000000'::uuid);

  IF v_filtered_ids IS NULL OR array_length(v_filtered_ids, 1) IS NULL THEN
    RETURN;
  END IF;

  v_payload := jsonb_build_object(
    'user_ids', v_filtered_ids,
    'title', p_title,
    'body', p_body,
    'data', p_data
  );

  -- Invoke send-push-notification Edge Function asynchronously via pg_net
  BEGIN
    PERFORM net.http_post(
      url := 'http://localhost:54321/functions/v1/send-push-notification',
      headers := '{"Content-Type": "application/json"}'::jsonb,
      body := v_payload
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'dispatch_push_notification net.http_post warning: %', SQLERRM;
  END;
END;
$$;

-- 2. Trigger on work_orders for assignment and reassignment
CREATE OR REPLACE FUNCTION public.handle_notify_work_order_assigned()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_target_user_ids UUID[] := ARRAY[]::UUID[];
  v_title TEXT;
  v_body TEXT;
BEGIN
  -- Determine target user
  IF NEW.assigned_to_id IS NOT NULL THEN
    v_target_user_ids := ARRAY[NEW.assigned_to_id];
  ELSIF NEW.provider_profile_id IS NOT NULL THEN
    SELECT ARRAY_AGG(auth_user_id) INTO v_target_user_ids
    FROM public.service_provider_profiles
    WHERE id = NEW.provider_profile_id;
  ELSIF NEW.service_provider_company_id IS NOT NULL THEN
    SELECT ARRAY_AGG(auth_user_id) INTO v_target_user_ids
    FROM public.service_provider_profiles
    WHERE service_provider_company_id = NEW.service_provider_company_id
      AND is_active = true;
  END IF;

  IF v_target_user_ids IS NULL OR array_length(v_target_user_ids, 1) IS NULL THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    v_title := 'Nova Ordem de Serviço';
    v_body := 'Você foi designado para a OS: ' || NEW.title;
  ELSIF TG_OP = 'UPDATE' THEN
    -- Only trigger if assignment changed
    IF (OLD.assigned_to_id IS DISTINCT FROM NEW.assigned_to_id) OR
       (OLD.provider_profile_id IS DISTINCT FROM NEW.provider_profile_id) OR
       (OLD.service_provider_company_id IS DISTINCT FROM NEW.service_provider_company_id) THEN
      v_title := 'OS Reatribuída';
      v_body := 'A OS ' || NEW.title || ' foi atribuída a você.';
    ELSE
      RETURN NEW;
    END IF;
  END IF;

  PERFORM public.dispatch_push_notification(
    v_target_user_ids,
    v_title,
    v_body,
    jsonb_build_object(
      'type', 'work_order',
      'work_order_id', NEW.id::text
    )
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_notify_work_order_assigned ON public.work_orders;
CREATE TRIGGER tr_notify_work_order_assigned
  AFTER INSERT OR UPDATE OF assigned_to_id, provider_profile_id, service_provider_company_id ON public.work_orders
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_notify_work_order_assigned();

-- 3. Trigger on work_order_pause_requests for pause / completion workflows
CREATE OR REPLACE FUNCTION public.handle_notify_pause_request()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_wo RECORD;
  v_manager_ids UUID[];
  v_title TEXT;
  v_body TEXT;
  v_event_label TEXT;
BEGIN
  -- Get work order details
  SELECT id, title, company_id
  INTO v_wo
  FROM public.work_orders
  WHERE id = NEW.work_order_id;

  IF v_wo.id IS NULL THEN
    RETURN NEW;
  END IF;

  v_event_label := CASE WHEN NEW.event_type = 'pause' THEN 'Pausa' ELSE 'Conclusão' END;

  IF TG_OP = 'INSERT' AND NEW.status = 'pending' THEN
    -- Find company managers / supervisors
    SELECT ARRAY_AGG(up.id)
    INTO v_manager_ids
    FROM public.user_profiles up
    LEFT JOIN public.permission_groups pg ON up.permission_group_id = pg.id
    WHERE up.company_id = v_wo.company_id
      AND up.is_active = true
      AND up.deleted_at IS NULL
      AND (
        COALESCE(up.is_admin, false) = true
        OR COALESCE(pg.permissions, '[]'::jsonb) ? '*'
        OR COALESCE(pg.permissions, '[]'::jsonb) ? 'work_orders.manage_pending_requests'
      );

    IF v_manager_ids IS NOT NULL AND array_length(v_manager_ids, 1) > 0 THEN
      v_title := 'Solicitação de ' || v_event_label;
      v_body := 'Nova solicitação de ' || lower(v_event_label) || ' na OS: ' || v_wo.title;

      PERFORM public.dispatch_push_notification(
        v_manager_ids,
        v_title,
        v_body,
        jsonb_build_object(
          'type', 'pause_request',
          'work_order_id', v_wo.id::text,
          'request_id', NEW.id::text,
          'event_type', NEW.event_type
        )
      );
    END IF;

  ELSIF TG_OP = 'UPDATE' AND OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected') THEN
    IF NEW.requested_by_id IS NOT NULL THEN
      v_title := v_event_label || ' ' || (CASE WHEN NEW.status = 'approved' THEN 'Aprovada' ELSE 'Rejeitada' END);
      v_body := 'Sua solicitação de ' || lower(v_event_label) || ' na OS ' || v_wo.title || ' foi ' || (CASE WHEN NEW.status = 'approved' THEN 'aprovada.' ELSE 'rejeitada.' END);

      PERFORM public.dispatch_push_notification(
        ARRAY[NEW.requested_by_id],
        v_title,
        v_body,
        jsonb_build_object(
          'type', 'pause_request_evaluated',
          'work_order_id', v_wo.id::text,
          'request_id', NEW.id::text,
          'status', NEW.status
        )
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_notify_pause_request ON public.work_order_pause_requests;
CREATE TRIGGER tr_notify_pause_request
  AFTER INSERT OR UPDATE OF status ON public.work_order_pause_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_notify_pause_request();

-- 4. Trigger on work_order_observations
CREATE OR REPLACE FUNCTION public.handle_notify_observation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_wo RECORD;
  v_target_user_ids UUID[] := ARRAY[]::UUID[];
  v_author_id UUID;
  v_assigned_user_id UUID;
BEGIN
  -- Determine author ID
  IF NEW.author_id IS NOT NULL THEN
    v_author_id := NEW.author_id;
  ELSIF NEW.author_provider_profile_id IS NOT NULL THEN
    SELECT auth_user_id INTO v_author_id
    FROM public.service_provider_profiles
    WHERE id = NEW.author_provider_profile_id;
  END IF;

  -- Get work order info
  SELECT id, title, created_by_id, assigned_to_id, provider_profile_id
  INTO v_wo
  FROM public.work_orders
  WHERE id = NEW.work_order_id;

  IF v_wo.id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Resolve assigned user ID
  IF v_wo.assigned_to_id IS NOT NULL THEN
    v_assigned_user_id := v_wo.assigned_to_id;
  ELSIF v_wo.provider_profile_id IS NOT NULL THEN
    SELECT auth_user_id INTO v_assigned_user_id
    FROM public.service_provider_profiles
    WHERE id = v_wo.provider_profile_id;
  END IF;

  -- If author is not the assigned technician, notify assigned tech
  IF v_assigned_user_id IS NOT NULL AND v_assigned_user_id != v_author_id THEN
    v_target_user_ids := ARRAY_APPEND(v_target_user_ids, v_assigned_user_id);
  END IF;

  -- If author is not creator, notify creator
  IF v_wo.created_by_id IS NOT NULL AND v_wo.created_by_id != v_author_id THEN
    v_target_user_ids := ARRAY_APPEND(v_target_user_ids, v_wo.created_by_id);
  END IF;

  IF array_length(v_target_user_ids, 1) > 0 THEN
    PERFORM public.dispatch_push_notification(
      v_target_user_ids,
      'Nova Observação na OS',
      'Uma nova observação foi adicionada na OS: ' || v_wo.title,
      jsonb_build_object(
        'type', 'observation',
        'work_order_id', v_wo.id::text,
        'observation_id', NEW.id::text
      )
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_notify_observation ON public.work_order_observations;
CREATE TRIGGER tr_notify_observation
  AFTER INSERT ON public.work_order_observations
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_notify_observation();
