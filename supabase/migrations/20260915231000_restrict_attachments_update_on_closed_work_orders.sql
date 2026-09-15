-- Migration: Restrict updating and soft-deleting attachments on closed or pending conclusion work orders

DROP POLICY IF EXISTS "Users update own company attachments with permission" ON public.attachments;

CREATE POLICY "Users update own company attachments with permission"
  ON public.attachments FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND (
      -- If parent work order is closed or pending conclusion, require manage_pending_requests
      (
        EXISTS (
          SELECT 1 FROM public.work_orders wo
          WHERE wo.id = attachments.work_order_id
            AND wo.status IN ('completed', 'cancelled', 'pending_conclusion')
        )
        AND public.has_permission('work_orders.manage_pending_requests')
      )
      OR (
        NOT EXISTS (
          SELECT 1 FROM public.work_orders wo
          WHERE wo.id = attachments.work_order_id
            AND wo.status IN ('completed', 'cancelled', 'pending_conclusion')
        )
        AND (
          public.has_permission('attachments.update')
          OR public.has_permission('attachments.delete')
        )
      )
    )
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
  );
