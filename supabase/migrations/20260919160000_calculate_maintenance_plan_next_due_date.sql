-- ==============================================================================
-- Migration: Add calculate_next_maintenance_plan_due_date Function & Trigger
-- ==============================================================================

-- 1. Create calculate_next_maintenance_plan_due_date function
CREATE OR REPLACE FUNCTION public.calculate_next_maintenance_plan_due_date(
  p_base_date TIMESTAMP WITH TIME ZONE,
  p_interval_value INT,
  p_interval_unit VARCHAR(20),
  p_day_of_week INT DEFAULT NULL,
  p_day_of_month INT DEFAULT NULL,
  p_month_of_year INT DEFAULT NULL
)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
DECLARE
  v_base TIMESTAMP WITH TIME ZONE;
  v_val INT;
  v_next TIMESTAMP WITH TIME ZONE;
  v_diff INT;
  v_dow INT;
  v_desired_day INT;
  v_desired_month INT;
  v_expected_month INT;
  v_candidate TIMESTAMP WITH TIME ZONE;
BEGIN
  v_base := COALESCE(p_base_date, now());
  v_val := GREATEST(COALESCE(p_interval_value, 1), 1);

  CASE p_interval_unit
    WHEN 'days' THEN
      RETURN v_base + (v_val || ' days')::INTERVAL;

    WHEN 'weeks' THEN
      v_next := v_base + (v_val || ' weeks')::INTERVAL;
      IF p_day_of_week IS NOT NULL AND p_day_of_week >= 1 AND p_day_of_week <= 7 THEN
        -- In Postgres EXTRACT(ISODOW FROM ...): Monday=1, Sunday=7 (matches ISO 8601 / Dart weekday)
        v_dow := EXTRACT(ISODOW FROM v_next)::INT;
        v_diff := p_day_of_week - v_dow;
        v_next := v_next + (v_diff || ' days')::INTERVAL;
        IF v_next <= v_base THEN
          v_next := v_next + INTERVAL '7 days';
        END IF;
      END IF;
      RETURN v_next;

    WHEN 'months' THEN
      -- Step ahead by interval months
      v_next := v_base + (v_val || ' months')::INTERVAL;
      v_desired_day := COALESCE(p_day_of_month, EXTRACT(DAY FROM v_base)::INT);
      
      -- Clamp day to valid days in target month
      DECLARE
        v_last_day_of_month INT;
      BEGIN
        v_last_day_of_month := EXTRACT(DAY FROM (date_trunc('month', v_next) + INTERVAL '1 month - 1 day'))::INT;
        IF v_desired_day > v_last_day_of_month THEN
          v_desired_day := v_last_day_of_month;
        END IF;
      END;

      RETURN make_timestamptz(
        EXTRACT(YEAR FROM v_next)::INT,
        EXTRACT(MONTH FROM v_next)::INT,
        v_desired_day,
        EXTRACT(HOUR FROM v_base)::INT,
        EXTRACT(MINUTE FROM v_base)::INT,
        EXTRACT(SECOND FROM v_base)
      );

    WHEN 'years' THEN
      v_next := v_base + (v_val || ' years')::INTERVAL;
      v_desired_month := COALESCE(p_month_of_year, EXTRACT(MONTH FROM v_base)::INT);
      v_desired_day := COALESCE(p_day_of_month, EXTRACT(DAY FROM v_base)::INT);

      DECLARE
        v_target_month_date TIMESTAMP WITH TIME ZONE;
        v_last_day_of_month INT;
      BEGIN
        v_target_month_date := make_timestamptz(EXTRACT(YEAR FROM v_next)::INT, v_desired_month, 1, 0, 0, 0);
        v_last_day_of_month := EXTRACT(DAY FROM (date_trunc('month', v_target_month_date) + INTERVAL '1 month - 1 day'))::INT;
        IF v_desired_day > v_last_day_of_month THEN
          v_desired_day := v_last_day_of_month;
        END IF;
      END;

      RETURN make_timestamptz(
        EXTRACT(YEAR FROM v_next)::INT,
        v_desired_month,
        v_desired_day,
        EXTRACT(HOUR FROM v_base)::INT,
        EXTRACT(MINUTE FROM v_base)::INT,
        EXTRACT(SECOND FROM v_base)
      );

    ELSE
      RETURN v_base + (v_val || ' months')::INTERVAL;
  END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 2. Trigger Function to set next_due_date on maintenance_plans
CREATE OR REPLACE FUNCTION public.handle_maintenance_plan_next_due_date()
RETURNS TRIGGER AS $$
BEGIN
  -- Compute next_due_date if NULL on INSERT, or if schedule parameters changed on UPDATE
  IF TG_OP = 'INSERT' THEN
    IF NEW.next_due_date IS NULL THEN
      NEW.next_due_date := public.calculate_next_maintenance_plan_due_date(
        COALESCE(NEW.created_at, now()),
        NEW.interval_value,
        NEW.interval_unit,
        NEW.day_of_week,
        NEW.day_of_month,
        NEW.month_of_year
      );
    END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    -- If schedule recurrence definition changed, or if next_due_date is still NULL
    IF NEW.next_due_date IS NULL OR (
      NEW.interval_value IS DISTINCT FROM OLD.interval_value OR
      NEW.interval_unit IS DISTINCT FROM OLD.interval_unit OR
      NEW.day_of_week IS DISTINCT FROM OLD.day_of_week OR
      NEW.day_of_month IS DISTINCT FROM OLD.day_of_month OR
      NEW.month_of_year IS DISTINCT FROM OLD.month_of_year
    ) THEN
      NEW.next_due_date := public.calculate_next_maintenance_plan_due_date(
        COALESCE(OLD.last_generated_at, NEW.created_at, now()),
        NEW.interval_value,
        NEW.interval_unit,
        NEW.day_of_week,
        NEW.day_of_month,
        NEW.month_of_year
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Create Trigger on maintenance_plans
DROP TRIGGER IF EXISTS tr_set_maintenance_plan_next_due_date ON public.maintenance_plans;

CREATE TRIGGER tr_set_maintenance_plan_next_due_date
  BEFORE INSERT OR UPDATE ON public.maintenance_plans
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_maintenance_plan_next_due_date();

-- 4. Backfill existing rows with null next_due_date
UPDATE public.maintenance_plans
SET next_due_date = public.calculate_next_maintenance_plan_due_date(
  COALESCE(last_generated_at, created_at, now()),
  interval_value,
  interval_unit,
  day_of_week,
  day_of_month,
  month_of_year
)
WHERE next_due_date IS NULL;
