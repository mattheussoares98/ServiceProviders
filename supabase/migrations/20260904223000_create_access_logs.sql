-- Migration: create access_logs table and RLS policies
-- Description: Immutable access log table to track login, logout, and app access events

CREATE TABLE IF NOT EXISTS public.access_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45),
    device_info VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for efficient lookups and chronological filtering per company and user
CREATE INDEX IF NOT EXISTS idx_access_logs_company_created_at ON public.access_logs(company_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_access_logs_company_user ON public.access_logs(company_id, user_id);

-- Enable RLS
ALTER TABLE public.access_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Internal users can view access logs of their company"
    ON public.access_logs
    FOR SELECT
    TO authenticated
    USING (
        company_id = public.get_user_company_id()
    );

CREATE POLICY "Authenticated users can insert access logs for their own company and user id"
    ON public.access_logs
    FOR INSERT
    TO authenticated
    WITH CHECK (
        company_id = public.get_user_company_id()
        AND user_id = auth.uid()
    );

-- Delete protection trigger
CREATE TRIGGER tr_prevent_delete_access_logs
BEFORE DELETE ON public.access_logs
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();
