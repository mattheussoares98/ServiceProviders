-- ==============================================================================
-- Migration: Add currency to company_parameters
-- ==============================================================================

-- 1. Add currency column to company_parameters with default 'BRL'
ALTER TABLE public.company_parameters
  ADD COLUMN IF NOT EXISTS currency VARCHAR(3) NOT NULL DEFAULT 'BRL'
  CONSTRAINT chk_company_parameters_currency CHECK (length(currency) = 3 AND currency = upper(currency));

COMMENT ON COLUMN public.company_parameters.currency IS
  'ISO 4217 3-letter currency code (e.g. BRL, USD, EUR). Defaults to BRL.';

-- 2. Update handle_new_company_parameters function to include default currency
CREATE OR REPLACE FUNCTION public.handle_new_company_parameters()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.company_parameters (
    company_id,
    currency,
    max_daily_work_orders,
    max_attachments_per_work_order,
    max_maintenance_plans,
    max_service_providers,
    max_observations_per_work_order
  ) VALUES (
    NEW.id,
    'BRL',
    CASE WHEN NEW.plan_type = 'free' THEN 3 ELSE 0 END,
    CASE WHEN NEW.plan_type = 'free' THEN 2 ELSE 0 END,
    0,
    0,
    CASE WHEN NEW.plan_type = 'free' THEN 2 ELSE 0 END
  )
  ON CONFLICT (company_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
