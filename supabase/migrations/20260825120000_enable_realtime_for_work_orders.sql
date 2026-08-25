-- Migration: Enable Realtime for work_orders table
-- Purpose: Gap 4 - Supabase Realtime synchronization for granular work order updates

ALTER PUBLICATION supabase_realtime ADD TABLE public.work_orders;
