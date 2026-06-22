-- Drop old unique constraints
ALTER TABLE public.locations DROP CONSTRAINT IF EXISTS uq_locations_company_name;
ALTER TABLE public.categories DROP CONSTRAINT IF EXISTS unique_category_name_per_company;
ALTER TABLE public.assets DROP CONSTRAINT IF EXISTS unique_code_per_company;
ALTER TABLE public.assets DROP CONSTRAINT IF EXISTS unique_serial_number_per_company;

-- Create partial unique indexes for soft-delete support (case-insensitive)
CREATE UNIQUE INDEX locations_company_name_active_idx
  ON public.locations (company_id, LOWER(name))
  WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX categories_company_name_active_idx
  ON public.categories (company_id, LOWER(name))
  WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX assets_company_code_active_idx
  ON public.assets (company_id, LOWER(code))
  WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX assets_company_serial_active_idx
  ON public.assets (company_id, LOWER(serial_number))
  WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX areas_location_name_active_idx
  ON public.areas (location_id, LOWER(name))
  WHERE deleted_at IS NULL;
