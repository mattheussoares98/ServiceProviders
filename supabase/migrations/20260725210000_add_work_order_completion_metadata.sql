-- ==========================================
-- Add event_type to work_order_pause_requests & completion metadata to work_orders
-- ==========================================

-- 1. Add event_type column to work_order_pause_requests (defaults to 'pause')
ALTER TABLE public.work_order_pause_requests
  ADD COLUMN IF NOT EXISTS event_type VARCHAR(20) NOT NULL DEFAULT 'pause'
  CONSTRAINT chk_event_type CHECK (event_type IN ('pause', 'completion'));

CREATE INDEX IF NOT EXISTS idx_wopr_event_type ON public.work_order_pause_requests(event_type);

-- 2. Add Completion Metadata fields to work_orders table (populated upon completion approval)
ALTER TABLE public.work_orders
  ADD COLUMN IF NOT EXISTS completion_reason VARCHAR(1000) NULL,
  ADD COLUMN IF NOT EXISTS completion_responsibility VARCHAR(20) NULL
  CONSTRAINT chk_wo_completion_resp CHECK (completion_responsibility IS NULL OR completion_responsibility IN ('provider', 'contractor', 'shared')),
  ADD COLUMN IF NOT EXISTS completion_sector_id UUID NULL REFERENCES public.sectors(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_wo_completion_sector ON public.work_orders(completion_sector_id);
