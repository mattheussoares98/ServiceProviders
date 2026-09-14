-- Migration: 20260914183000_fix_access_logs_insert_rls.sql
-- Description: Allow super admins and users to insert access logs for companies they access

DROP POLICY IF EXISTS "Authenticated users can insert access logs for their own company and user id" ON public.access_logs;

CREATE POLICY "Authenticated users can insert access logs for their own company and user id"
    ON public.access_logs
    FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = auth.uid()
        AND (
            company_id = public.get_user_company_id()
            OR public.is_super_admin()
            OR EXISTS (
                SELECT 1
                FROM public.service_provider_profiles spp
                JOIN public.service_provider_companies spc
                  ON spc.id = spp.service_provider_company_id
                WHERE spp.auth_user_id = auth.uid()
                  AND spc.company_id = access_logs.company_id
                  AND spp.is_active = true
                  AND spc.is_active = true
            )
        )
    );
