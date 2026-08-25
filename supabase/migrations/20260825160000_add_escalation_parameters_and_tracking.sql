-- ========================================================
-- Migration: Add Escalation & Advance Warning Parameters and Engine
-- ========================================================

-- 1. Add escalation configuration parameters to company_parameters
ALTER TABLE public.company_parameters
  ADD COLUMN IF NOT EXISTS advance_warning_minutes INTEGER NOT NULL DEFAULT 60 CONSTRAINT chk_advance_warning_minutes CHECK (advance_warning_minutes >= 0),
  ADD COLUMN IF NOT EXISTS advance_warning_group_ids JSONB NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS delayed_notification_interval_minutes INTEGER NOT NULL DEFAULT 60 CONSTRAINT chk_delayed_notification_interval_minutes CHECK (delayed_notification_interval_minutes > 0),
  ADD COLUMN IF NOT EXISTS escalation_group_ids JSONB NOT NULL DEFAULT '[]'::jsonb;

-- 2. Add escalation tracking columns to work_orders
ALTER TABLE public.work_orders
  ADD COLUMN IF NOT EXISTS advance_warning_sent_at TIMESTAMP WITH TIME ZONE NULL,
  ADD COLUMN IF NOT EXISTS last_escalation_level INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_escalation_at TIMESTAMP WITH TIME ZONE NULL;

-- 3. Escalation and Advance Warning Evaluation Engine
CREATE OR REPLACE FUNCTION public.evaluate_work_order_escalations()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  rec RECORD;
  v_recipients UUID[];
  v_target_group_id TEXT;
  v_next_level INT;
  v_group_count INT;
BEGIN
  -- Iterate through active work orders with SLA deadlines
  FOR rec IN
    SELECT
      wo.id,
      wo.company_id,
      wo.title,
      wo.assigned_to_id,
      wo.sla_deadline_at,
      wo.sla_breached,
      wo.advance_warning_sent_at,
      wo.last_escalation_level,
      wo.last_escalation_at,
      COALESCE(cp.advance_warning_minutes, 60) AS advance_warning_minutes,
      COALESCE(cp.advance_warning_group_ids, '[]'::jsonb) AS advance_warning_group_ids,
      COALESCE(cp.delayed_notification_interval_minutes, 60) AS delayed_notification_interval_minutes,
      COALESCE(cp.escalation_group_ids, '[]'::jsonb) AS escalation_group_ids
    FROM public.work_orders wo
    LEFT JOIN public.company_parameters cp ON cp.company_id = wo.company_id
    WHERE wo.status IN ('open', 'in_progress', 'on_hold')
      AND wo.sla_deadline_at IS NOT NULL
      AND wo.deleted_at IS NULL
  LOOP
    -- ----------------------------------------------------
    -- Branch A: Advance Warning (Approaching SLA Deadline)
    -- ----------------------------------------------------
    IF rec.advance_warning_minutes > 0
       AND now() >= (rec.sla_deadline_at - (rec.advance_warning_minutes || ' minutes')::interval)
       AND now() < rec.sla_deadline_at
       AND rec.advance_warning_sent_at IS NULL
    THEN
      v_recipients := ARRAY[]::UUID[];

      -- Include assigned technician/user
      IF rec.assigned_to_id IS NOT NULL THEN
        v_recipients := array_append(v_recipients, rec.assigned_to_id);
      END IF;

      -- Include users from advance warning permission groups
      IF jsonb_array_length(rec.advance_warning_group_ids) > 0 THEN
        SELECT ARRAY_AGG(DISTINCT id)
        INTO v_recipients
        FROM (
          SELECT UNNEST(v_recipients) AS id
          UNION
          SELECT up.id
          FROM public.user_profiles up
          WHERE up.company_id = rec.company_id
            AND up.deleted_at IS NULL
            AND up.permission_group_id::text IN (
              SELECT jsonb_array_elements_text(rec.advance_warning_group_ids)
            )
        ) s;
      END IF;

      -- Dispatch notification
      IF v_recipients IS NOT NULL AND array_length(v_recipients, 1) > 0 THEN
        PERFORM public.dispatch_push_notification(
          v_recipients,
          'Aviso de Prazo',
          'A OS "' || rec.title || '" vence em breve.',
          jsonb_build_object('type', 'work_order_advance_warning', 'work_order_id', rec.id)
        );
      END IF;

      -- Mark advance warning as sent
      UPDATE public.work_orders
      SET advance_warning_sent_at = now()
      WHERE id = rec.id;
    END IF;

    -- ----------------------------------------------------
    -- Branch B: Delayed / Overdue Escalation (Past SLA Deadline)
    -- ----------------------------------------------------
    IF now() >= rec.sla_deadline_at THEN
      -- Automatically mark SLA as breached if not already marked
      IF NOT rec.sla_breached THEN
        UPDATE public.work_orders
        SET sla_breached = true
        WHERE id = rec.id;
      END IF;

      -- Check if notification interval elapsed
      IF rec.last_escalation_at IS NULL
         OR now() >= (rec.last_escalation_at + (rec.delayed_notification_interval_minutes || ' minutes')::interval)
      THEN
        v_next_level := rec.last_escalation_level + 1;
        v_group_count := jsonb_array_length(rec.escalation_group_ids);
        v_recipients := ARRAY[]::UUID[];

        -- Always include assigned user
        IF rec.assigned_to_id IS NOT NULL THEN
          v_recipients := array_append(v_recipients, rec.assigned_to_id);
        END IF;

        -- Resolve target escalation group for current tier
        IF v_group_count > 0 THEN
          -- Pick the group for this tier or clamp to the highest configured tier
          IF v_next_level <= v_group_count THEN
            v_target_group_id := rec.escalation_group_ids->>(v_next_level - 1);
          ELSE
            v_target_group_id := rec.escalation_group_ids->>(v_group_count - 1);
          END IF;

          IF v_target_group_id IS NOT NULL THEN
            SELECT ARRAY_AGG(DISTINCT id)
            INTO v_recipients
            FROM (
              SELECT UNNEST(v_recipients) AS id
              UNION
              SELECT up.id
              FROM public.user_profiles up
              WHERE up.company_id = rec.company_id
                AND up.deleted_at IS NULL
                AND up.permission_group_id::text = v_target_group_id
            ) s;
          END IF;
        END IF;

        -- Dispatch escalation push notification
        IF v_recipients IS NOT NULL AND array_length(v_recipients, 1) > 0 THEN
          PERFORM public.dispatch_push_notification(
            v_recipients,
            'OS Atrasada (Nível ' || v_next_level || ')',
            'A OS "' || rec.title || '" ultrapassou o prazo de SLA.',
            jsonb_build_object('type', 'work_order_escalated', 'work_order_id', rec.id, 'level', v_next_level)
          );
        END IF;

        -- Update escalation state on work order
        UPDATE public.work_orders
        SET last_escalation_level = v_next_level,
            last_escalation_at = now()
        WHERE id = rec.id;
      END IF;
    END IF;
  END LOOP;
END;
$$;

-- 4. Schedule periodic escalation evaluation in pg_cron (every 5 minutes)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    BEGIN
      -- Unschedule existing job if present
      PERFORM cron.unschedule('evaluate-work-order-escalations');
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
    
    PERFORM cron.schedule(
      'evaluate-work-order-escalations',
      '*/5 * * * *',
      'SELECT public.evaluate_work_order_escalations();'
    );
  END IF;
END $$;
