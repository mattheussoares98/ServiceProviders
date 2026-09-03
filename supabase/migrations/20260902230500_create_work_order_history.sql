-- Create work_order_history table
CREATE TABLE IF NOT EXISTS public.work_order_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    work_order_id UUID NOT NULL REFERENCES public.work_orders(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    action VARCHAR(100) NOT NULL,
    old_value VARCHAR(2000),
    new_value VARCHAR(2000),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_work_order_history_work_order_id ON public.work_order_history(work_order_id);
CREATE INDEX IF NOT EXISTS idx_work_order_history_company_id ON public.work_order_history(company_id);
CREATE INDEX IF NOT EXISTS idx_work_order_history_created_at ON public.work_order_history(created_at);

-- Hard delete protection
CREATE TRIGGER tr_prevent_delete_work_order_history
BEFORE DELETE ON public.work_order_history
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

-- Enable RLS
ALTER TABLE public.work_order_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view work order history of their company"
    ON public.work_order_history
    FOR SELECT
    TO authenticated
    USING (
        company_id = public.get_user_company_id()
        OR public.is_provider_member_of_work_order_id(work_order_id)
    );

CREATE POLICY "Users can insert work order history for their company"
    ON public.work_order_history
    FOR INSERT
    TO authenticated
    WITH CHECK (
        company_id = public.get_user_company_id()
        OR public.is_provider_member_of_work_order_id(work_order_id)
    );
