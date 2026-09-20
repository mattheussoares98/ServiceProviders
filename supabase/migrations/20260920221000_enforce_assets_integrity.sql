-- Migration: Enforce integrity on assets table
-- 1. Clean up any invalid self-referencing assets
UPDATE public.assets
SET parent_asset_id = NULL
WHERE parent_asset_id = id;

-- 2. Add constraints for non-empty name and no self-parenting
ALTER TABLE public.assets
    ADD CONSTRAINT chk_assets_name_not_empty
    CHECK (length(trim(name)) > 0),
    ADD CONSTRAINT chk_assets_not_self_parent
    CHECK (parent_asset_id IS NULL OR parent_asset_id != id);

-- 3. Update check_asset_before_delete trigger function to also check for active sub-assets
CREATE OR REPLACE FUNCTION public.check_asset_before_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    -- Block if there are active work orders
    IF EXISTS (
      SELECT 1 
      FROM public.work_orders 
      WHERE asset_id = OLD.id 
        AND status != 'completed' 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir este equipamento porque ele possui ordens de serviço ativas.';
    END IF;

    -- Block if there are active child assets
    IF EXISTS (
      SELECT 1
      FROM public.assets
      WHERE parent_asset_id = OLD.id
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir ativo com subativos vinculados.';
    END IF;
  END IF;
  RETURN NEW;
END;
$function$;
