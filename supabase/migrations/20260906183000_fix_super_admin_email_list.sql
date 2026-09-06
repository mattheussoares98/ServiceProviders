-- Remove technician test email from is_super_admin() list
-- The technician email (mattheussbarosa98@gmail.com) is used as a standard non-admin / scoped role in integration tests.
-- Having it hardcoded in is_super_admin() bypassed all RLS permission checks for the technician identity.

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth
AS $$
  SELECT COALESCE(
    LOWER(TRIM((SELECT email FROM auth.users WHERE id = auth.uid()))) IN (
      'mattheussbarbosa@hotmail.com',
      'thiago.saraiva@kephasengenharia.com.br'
    ),
    false
  );
$$;
