-- ==============================================================================
-- Migration: Create Checklist Answers Table
-- ------------------------------------------------------------------------------
-- Checklist execution answers were being written to (and read from) `tasks`,
-- which has none of the answer columns. This creates the table the client has
-- always serialised for.
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.checklist_answers (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL DEFAULT public.get_user_company_id()
    REFERENCES public.companies(id) ON DELETE CASCADE,
  work_order_id UUID NOT NULL REFERENCES public.work_orders(id) ON DELETE CASCADE,
  checklist_item_id UUID NOT NULL REFERENCES public.checklist_items(id) ON DELETE CASCADE,
  boolean_value BOOLEAN NULL,
  text_value VARCHAR(2000) NULL,
  number_value NUMERIC NULL,
  photo_url VARCHAR(2000) NULL,
  selected_option VARCHAR(500) NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_checklist_answers_unique_item
  ON public.checklist_answers(work_order_id, checklist_item_id);
CREATE INDEX IF NOT EXISTS idx_checklist_answers_work_order
  ON public.checklist_answers(work_order_id);
CREATE INDEX IF NOT EXISTS idx_checklist_answers_company
  ON public.checklist_answers(company_id);

ALTER TABLE public.checklist_answers ENABLE ROW LEVEL SECURITY;

-- Read: company users, or a service provider profile of a hiring tenant.
CREATE POLICY "Users read own company checklist answers"
  ON public.checklist_answers FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.service_provider_profiles spp
      JOIN public.service_provider_companies spc ON spp.service_provider_company_id = spc.id
      WHERE spp.auth_user_id = auth.uid() AND spc.company_id = public.checklist_answers.company_id
    )
  );

-- Insert: answering a checklist is executing the work order, so it is gated by
-- the work order update scope, not by a checklists key.
CREATE POLICY "Users insert own company checklist answers"
  ON public.checklist_answers FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND EXISTS (
      SELECT 1 FROM public.work_orders wo
      WHERE wo.id = public.checklist_answers.work_order_id
    )
  );

CREATE POLICY "Users update own company checklist answers"
  ON public.checklist_answers FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND EXISTS (
      SELECT 1 FROM public.work_orders wo
      WHERE wo.id = public.checklist_answers.work_order_id
    )
  );

CREATE TRIGGER tr_prevent_delete_checklist_answers
BEFORE DELETE ON public.checklist_answers
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

ALTER TABLE public.checklist_answers REPLICA IDENTITY FULL;
