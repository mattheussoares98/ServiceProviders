-- Migration: Enforce locations and areas integrity
-- 1. Disallow empty or whitespace-only names on locations and areas
-- 2. Prevent soft-deleting locations with active areas
-- 3. Prevent creating or updating areas pointing to a soft-deleted location

ALTER TABLE public.locations
  ADD CONSTRAINT chk_locations_name_not_empty CHECK (length(trim(name)) > 0);

ALTER TABLE public.areas
  ADD CONSTRAINT chk_areas_name_not_empty CHECK (length(trim(name)) > 0);

-- Update check_location_before_delete() to also check for active areas
CREATE OR REPLACE FUNCTION public.check_location_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    -- Check for active areas
    IF EXISTS (
      SELECT 1 
      FROM public.areas ar
      WHERE ar.location_id = OLD.id 
        AND ar.deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir este local porque ele possui áreas vinculadas.';
    END IF;

    -- Check for active assets
    IF EXISTS (
      SELECT 1 
      FROM public.assets a
      JOIN public.areas ar ON a.area_id = ar.id
      WHERE ar.location_id = OLD.id 
        AND a.deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir este local porque ele possui equipamentos ativos.';
    END IF;

    -- Check for active work orders
    IF EXISTS (
      SELECT 1 
      FROM public.work_orders 
      WHERE location_id = OLD.id 
        AND status != 'completed' 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir este local porque ele possui ordens de serviço ativas.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to prevent creating or updating areas linked to soft-deleted locations
CREATE OR REPLACE FUNCTION public.check_area_parent_location()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM public.locations
    WHERE id = NEW.location_id
      AND deleted_at IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'Não é possível vincular uma área a um local excluído.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_check_area_parent_location ON public.areas;
CREATE TRIGGER tr_check_area_parent_location
  BEFORE INSERT OR UPDATE OF location_id ON public.areas
  FOR EACH ROW
  EXECUTE FUNCTION public.check_area_parent_location();
