-- Migration: Enforce status-based restrictions on work orders and observations

-- 1. Function to prevent deleting closed or pending conclusion work orders
CREATE OR REPLACE FUNCTION public.check_work_order_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    -- Block deletion if work order is concluded or pending conclusion
    IF OLD.status = 'completed' THEN
      RAISE EXCEPTION 'Não é possível excluir uma ordem de serviço concluída.';
    END IF;

    IF OLD.status = 'pending_conclusion' THEN
      RAISE EXCEPTION 'Não é possível excluir uma ordem de serviço com solicitação de conclusão pendente.';
    END IF;

    -- Also check if there is an active/pending pause or completion request
    IF EXISTS (
      SELECT 1 
      FROM public.work_order_pause_requests 
      WHERE work_order_id = OLD.id 
        AND status = 'pending' 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir uma ordem de serviço com solicitações pendentes de aprovação.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Attach trigger to work_orders
DROP TRIGGER IF EXISTS tr_prevent_delete_work_orders_with_status ON public.work_orders;
CREATE TRIGGER tr_prevent_delete_work_orders_with_status
  BEFORE UPDATE ON public.work_orders
  FOR EACH ROW
  EXECUTE FUNCTION public.check_work_order_before_delete();

-- 3. Update RLS policy for work_orders update (require manage_pending_requests if closed)
DROP POLICY IF EXISTS "Users update own company work orders with permission" ON public.work_orders;

CREATE POLICY "Users update own company work orders with permission"
  ON public.work_orders FOR UPDATE
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND (
        -- If closed, only users with manage_pending_requests can update
        (
          status NOT IN ('completed', 'cancelled')
          AND (
            public.get_work_orders_update_scope() = 'all'
            OR (public.get_work_orders_update_scope() = 'assigned' AND assigned_to_id = auth.uid())
            OR (public.get_work_orders_update_scope() = 'own' AND created_by_id = auth.uid())
          )
        )
        OR (
          status IN ('completed', 'cancelled')
          AND public.has_permission('work_orders.manage_pending_requests')
        )
      )
    )
    OR (
      status NOT IN ('completed', 'cancelled')
      AND public.is_provider_member_of_work_order(service_provider_company_id, provider_profile_id)
    )
  )
  WITH CHECK (
    (
      company_id = public.get_user_company_id()
      AND (
        (
          status NOT IN ('completed', 'cancelled')
          AND (
            public.get_work_orders_update_scope() = 'all'
            OR (public.get_work_orders_update_scope() = 'assigned' AND assigned_to_id = auth.uid())
            OR (public.get_work_orders_update_scope() = 'own' AND created_by_id = auth.uid())
          )
        )
        OR (
          status IN ('completed', 'cancelled')
          AND public.has_permission('work_orders.manage_pending_requests')
        )
      )
    )
    OR (
      status NOT IN ('completed', 'cancelled')
      AND public.is_provider_member_of_work_order(service_provider_company_id, provider_profile_id)
    )
  );

-- 4. Update RLS policy for work_order_observations update / soft delete
DROP POLICY IF EXISTS "Users can update observations of their company" ON public.work_order_observations;

CREATE POLICY "Users can update observations of their company"
  ON public.work_order_observations FOR UPDATE
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND (
        -- If parent work order is closed or pending conclusion, require manage_pending_requests
        EXISTS (
          SELECT 1 FROM public.work_orders wo
          WHERE wo.id = work_order_observations.work_order_id
            AND wo.status IN ('completed', 'cancelled', 'pending_conclusion')
        )
        AND public.has_permission('work_orders.manage_pending_requests')
      )
      OR (
        company_id = public.get_user_company_id()
        AND NOT EXISTS (
          SELECT 1 FROM public.work_orders wo
          WHERE wo.id = work_order_observations.work_order_id
            AND wo.status IN ('completed', 'cancelled', 'pending_conclusion')
        )
        AND (
          author_id = auth.uid()
          OR public.has_permission('work_orders.delete_observation')
          OR public.has_permission('work_orders.update')
        )
      )
    )
    OR (
      public.is_provider_member_of_work_order_id(work_order_id)
      AND public.is_own_provider_profile(author_provider_profile_id)
      AND NOT EXISTS (
        SELECT 1 FROM public.work_orders wo
        WHERE wo.id = work_order_observations.work_order_id
          AND wo.status IN ('completed', 'cancelled', 'pending_conclusion')
      )
    )
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );
