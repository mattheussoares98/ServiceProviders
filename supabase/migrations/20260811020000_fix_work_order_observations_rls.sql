-- Fix RLS policies for viewing, inserting, updating, and soft-deleting work_order_observations
DROP POLICY IF EXISTS "Users can view observations of their company" ON public.work_order_observations;
DROP POLICY IF EXISTS "Users can insert observations into work orders of their company" ON public.work_order_observations;
DROP POLICY IF EXISTS "Users can update observations of their company" ON public.work_order_observations;
DROP POLICY IF EXISTS "Users can soft delete observations of their company" ON public.work_order_observations;

CREATE POLICY "Users can view observations of their company"
    ON public.work_order_observations
    FOR SELECT
    USING (
        company_id = public.get_user_company_id()
    );

CREATE POLICY "Users can insert observations into work orders of their company"
    ON public.work_order_observations
    FOR INSERT
    WITH CHECK (
        company_id = public.get_user_company_id()
        AND (
            author_id = auth.uid()
            OR public.has_permission('work_orders.update')
        )
    );

CREATE POLICY "Users can update observations of their company"
    ON public.work_order_observations
    FOR UPDATE
    USING (
        company_id = public.get_user_company_id()
        AND (
            author_id = auth.uid()
            OR public.has_permission('work_orders.delete_observation')
            OR public.has_permission('work_orders.update')
        )
    )
    WITH CHECK (
        company_id = public.get_user_company_id()
    );
