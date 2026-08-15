-- Make responsibility nullable on work_order_pause_requests and add check constraint for review status
ALTER TABLE public.work_order_pause_requests
  ALTER COLUMN responsibility DROP NOT NULL;

-- Ensure that reviewed requests (approved or rejected) must have a responsibility assigned
ALTER TABLE public.work_order_pause_requests
  ADD CONSTRAINT chk_responsibility_on_review
  CHECK (
    status NOT IN ('approved', 'rejected') OR responsibility IS NOT NULL
  );
