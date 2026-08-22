-- Freezes the provider's attachment set once the work order leaves execution.
--
-- 20260820120000 gave providers an INSERT branch on attachments keyed only off
-- membership of the assigned provider company, with no status condition. Since
-- the work order details page now exposes an "Adicionar" button to providers
-- (the create/update form is closed to them, so it was their only way in), a
-- stale or hand-rolled client could still attach to an order whose conclusion is
-- already awaiting approval — changing the evidence the approver is reviewing —
-- or to one already completed or cancelled. The gate belongs here, not only in
-- the UI.
--
-- The internal-employee branch is deliberately left untouched: internal users
-- still attach through the create/update form, which the change request queue
-- opens for closed work orders on purpose.
--
-- Providers have no DELETE branch on attachments and this migration does not add
-- one — erasing evidence stays with the contracting company.

CREATE OR REPLACE FUNCTION public.work_order_accepts_attachments(p_work_order_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.work_orders wo
    WHERE wo.id = p_work_order_id
      AND wo.deleted_at IS NULL
      AND wo.status IN ('open', 'in_progress', 'on_hold')
  );
$$;

COMMENT ON FUNCTION public.work_order_accepts_attachments(UUID) IS
  'True while the work order is still being executed (open / in_progress / on_hold). False once conclusion is pending approval, or the order is completed or cancelled.';

REVOKE EXECUTE ON FUNCTION public.work_order_accepts_attachments(UUID) FROM anon;

DROP POLICY IF EXISTS "Users insert own company attachments with permission" ON public.attachments;
CREATE POLICY "Users insert own company attachments with permission"
  ON public.attachments FOR INSERT
  TO authenticated
  WITH CHECK (
    (company_id = public.get_user_company_id() AND public.has_permission('attachments.create'))
    OR (
      public.is_provider_member_of_work_order_id(work_order_id)
      AND public.work_order_accepts_attachments(work_order_id)
    )
  );
