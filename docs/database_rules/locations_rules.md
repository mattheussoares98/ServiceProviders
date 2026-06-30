# Locations Table Policies

```sql
CREATE POLICY "Users read own company locations with permission"
  ON public.locations FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('locations.read')
  );

CREATE POLICY "Users insert own company locations with permission"
  ON public.locations FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('locations.create')
  );

CREATE POLICY "Users update own company locations with permission"
  ON public.locations FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('locations.update')
  );
```

## Soft-Delete Prevention Trigger

Soft-deleting a location is only allowed if there are no active assets and no open work orders associated with it.

```sql
CREATE OR REPLACE FUNCTION public.check_location_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
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

CREATE OR REPLACE TRIGGER tr_prevent_delete_locations_with_relations
  BEFORE UPDATE ON public.locations
  FOR EACH ROW
  EXECUTE FUNCTION public.check_location_before_delete();
```
