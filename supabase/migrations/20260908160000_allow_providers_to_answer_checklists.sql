-- ==============================================================================
-- Migration: Let service providers answer the checklist of orders they execute
-- ------------------------------------------------------------------------------
-- `checklist_answers` carried a provider branch on SELECT only. INSERT and UPDATE
-- still required `company_id = public.get_user_company_id()`, so a provider could
-- read the checklist of an order it executes but never answer it — and, with a
-- mandatory item, could never request completion either.
--
-- Two things blocked the write:
--   1. the policies had no `is_provider_member_of_work_order_id` branch, unlike
--      attachments and observations (20260820120000);
--   2. `company_id` defaults to `get_user_company_id()`, which is not the
--      contracting company for a provider, so the NOT NULL default filled the
--      wrong value (or none at all).
--
-- The company of an answer is never the writer's own — it is always the company
-- of the parent work order. Deriving it in a BEFORE trigger fixes (2) and also
-- stops a caller from spoofing another tenant's company_id.
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.set_checklist_answer_company()
RETURNS TRIGGER AS $$
BEGIN
  SELECT wo.company_id INTO NEW.company_id
  FROM public.work_orders wo
  WHERE wo.id = NEW.work_order_id;

  IF NEW.company_id IS NULL THEN
    RAISE EXCEPTION 'Ordem de serviço não encontrada para a resposta do checklist.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS tr_set_checklist_answer_company ON public.checklist_answers;
CREATE TRIGGER tr_set_checklist_answer_company
  BEFORE INSERT OR UPDATE ON public.checklist_answers
  FOR EACH ROW
  EXECUTE FUNCTION public.set_checklist_answer_company();

-- Answering is executing the work order, so the write is gated by access to the
-- parent order — the company user via their work order scope, the provider via
-- its assignment — not by a `checklists.*` key, which stays for authoring.
DROP POLICY IF EXISTS "Users insert own company checklist answers" ON public.checklist_answers;
CREATE POLICY "Users insert own company checklist answers"
  ON public.checklist_answers FOR INSERT
  TO authenticated
  WITH CHECK (
    (
      company_id = public.get_user_company_id()
      AND EXISTS (
        SELECT 1 FROM public.work_orders wo
        WHERE wo.id = public.checklist_answers.work_order_id
      )
    )
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );

DROP POLICY IF EXISTS "Users update own company checklist answers" ON public.checklist_answers;
CREATE POLICY "Users update own company checklist answers"
  ON public.checklist_answers FOR UPDATE
  TO authenticated
  USING (
    (
      company_id = public.get_user_company_id()
      AND EXISTS (
        SELECT 1 FROM public.work_orders wo
        WHERE wo.id = public.checklist_answers.work_order_id
      )
    )
    OR public.is_provider_member_of_work_order_id(work_order_id)
  )
  -- Without WITH CHECK an update could move a row to another tenant; the trigger
  -- already pins company_id, this refuses anything it could not have produced.
  WITH CHECK (
    company_id = public.get_user_company_id()
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );
