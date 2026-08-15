-- Update responsibility check constraint so that responsibility is only mandatory when reviewing pause events
ALTER TABLE public.work_order_pause_requests
  DROP CONSTRAINT IF EXISTS chk_responsibility_on_review;

ALTER TABLE public.work_order_pause_requests
  ADD CONSTRAINT chk_responsibility_on_review
  CHECK (
    event_type != 'pause'
    OR status NOT IN ('approved', 'rejected')
    OR responsibility IS NOT NULL
  );
