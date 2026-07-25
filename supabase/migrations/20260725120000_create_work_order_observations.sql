-- Create work_order_observations table
CREATE TABLE IF NOT EXISTS public.work_order_observations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    work_order_id UUID NOT NULL REFERENCES public.work_orders(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE RESTRICT,
    content VARCHAR(2000) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_work_order_observations_work_order_id ON public.work_order_observations(work_order_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_work_order_observations_company_id ON public.work_order_observations(company_id) WHERE deleted_at IS NULL;

-- Enable RLS
ALTER TABLE public.work_order_observations ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view observations of their company"
    ON public.work_order_observations
    FOR SELECT
    USING (
        company_id = public.get_user_company_id()
        AND deleted_at IS NULL
    );

CREATE POLICY "Users can insert observations into work orders of their company"
    ON public.work_order_observations
    FOR INSERT
    WITH CHECK (
        company_id = public.get_user_company_id()
        AND author_id = auth.uid()
    );

CREATE POLICY "Users can update observations of their company"
    ON public.work_order_observations
    FOR UPDATE
    USING (
        company_id = public.get_user_company_id()
        AND deleted_at IS NULL
    );

CREATE POLICY "Users can soft delete observations of their company"
    ON public.work_order_observations
    FOR DELETE
    USING (
        company_id = public.get_user_company_id()
        AND (
            author_id = auth.uid()
            OR public.has_permission('work_orders.delete_observation')
        )
    );
