-- Migration: Create customers table and adapt work_orders and assets for flexible WorkType support
-- 1. Create customers table (CRM entity)
CREATE TABLE IF NOT EXISTS public.customers (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  document VARCHAR(14) NULL,
  document_type VARCHAR(4) NULL,
  contact_name VARCHAR(255) NULL,
  contact_email VARCHAR(255) NULL,
  contact_phone VARCHAR(30) NULL,
  address VARCHAR(500) NULL,
  notes VARCHAR(2000) NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL,
  CONSTRAINT chk_customers_name_not_empty CHECK (length(trim(name)) > 0),
  CONSTRAINT chk_customers_document_type CHECK (document_type IS NULL OR lower(document_type) IN ('cpf', 'cnpj'))
);

-- Indexes for customers
CREATE INDEX IF NOT EXISTS idx_customers_company ON public.customers(company_id);
CREATE UNIQUE INDEX IF NOT EXISTS unique_customer_document_per_company_idx 
  ON public.customers (company_id, document) 
  WHERE deleted_at IS NULL AND document IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS unique_customer_name_per_company_idx 
  ON public.customers (company_id, lower(trim(name))) 
  WHERE deleted_at IS NULL;

-- Enable RLS on customers
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- Read policy: members of same company or hired service providers
DROP POLICY IF EXISTS "Users read own company customers" ON public.customers;
CREATE POLICY "Users read own company customers"
  ON public.customers FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR public.is_provider_of_company(company_id)
  );

-- Insert policy: company users with customers.create permission
DROP POLICY IF EXISTS "Users insert own company customers with permission" ON public.customers;
CREATE POLICY "Users insert own company customers with permission"
  ON public.customers FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('customers.create')
  );

-- Update policy: company users with customers.update or customers.delete permission
DROP POLICY IF EXISTS "Users update own company customers with permission" ON public.customers;
CREATE POLICY "Users update own company customers with permission"
  ON public.customers FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND (
      public.has_permission('customers.update')
      OR public.has_permission('customers.delete')
    )
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
  );

-- Delete protection: prevent hard delete
DROP TRIGGER IF EXISTS tr_prevent_delete_customers ON public.customers;
CREATE TRIGGER tr_prevent_delete_customers
BEFORE DELETE ON public.customers
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

-- Soft-delete protection: prevent deletion if active work orders reference this customer
CREATE OR REPLACE FUNCTION public.check_customer_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    IF EXISTS (
      SELECT 1 
      FROM public.work_orders 
      WHERE customer_id = OLD.id 
        AND status != 'completed' 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir este cliente porque ele possui ordens de serviço ativas.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_prevent_delete_customers_with_relations ON public.customers;
CREATE TRIGGER tr_prevent_delete_customers_with_relations
  BEFORE UPDATE ON public.customers
  FOR EACH ROW
  EXECUTE FUNCTION public.check_customer_before_delete();

-- Audit logging for customers
DROP TRIGGER IF EXISTS tr_audit_customers ON public.customers;
CREATE TRIGGER tr_audit_customers
AFTER INSERT OR UPDATE ON public.customers
FOR EACH ROW EXECUTE FUNCTION public.handle_generic_audit();

-- Realtime publication and replica identity
ALTER PUBLICATION supabase_realtime ADD TABLE public.customers;
ALTER TABLE public.customers REPLICA IDENTITY FULL;

-- 2. Adapt work_orders table
-- Make location_id nullable and add customer_id
ALTER TABLE public.work_orders ALTER COLUMN location_id DROP NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'work_orders' AND column_name = 'customer_id'
  ) THEN
    ALTER TABLE public.work_orders 
      ADD COLUMN customer_id UUID NULL REFERENCES public.customers(id) ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_work_orders_customer ON public.work_orders(customer_id);

-- 3. Adapt assets table
-- Add location_id and customer_id, backfill location_id from areas, and make area_id nullable
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'assets' AND column_name = 'location_id'
  ) THEN
    ALTER TABLE public.assets 
      ADD COLUMN location_id UUID NULL REFERENCES public.locations(id) ON DELETE SET NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'assets' AND column_name = 'customer_id'
  ) THEN
    ALTER TABLE public.assets 
      ADD COLUMN customer_id UUID NULL REFERENCES public.customers(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Backfill location_id from area's location_id for existing assets
UPDATE public.assets a
SET location_id = ar.location_id
FROM public.areas ar
WHERE a.area_id = ar.id AND a.location_id IS NULL;

-- Make area_id nullable on assets
ALTER TABLE public.assets ALTER COLUMN area_id DROP NOT NULL;

CREATE INDEX IF NOT EXISTS idx_assets_location ON public.assets(location_id);
CREATE INDEX IF NOT EXISTS idx_assets_customer ON public.assets(customer_id);

-- 4. Update default permissions for Supervisor in handle_new_company
CREATE OR REPLACE FUNCTION public.handle_new_company()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert Administrador group
  INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
  VALUES (gen_random_uuid(), NEW.id, 'Administrador', '{"*": true}'::jsonb, true, now());

  -- Insert Supervisor group with all canonical permission keys including customers
  INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
  VALUES (gen_random_uuid(), NEW.id, 'Supervisor', 
    '{
      "work_orders.read_scope": "all",
      "work_orders.create": true,
      "work_orders.update_scope": "all",
      "work_orders.delete": true,
      "work_orders.change_status": true,
      "work_orders.reassign": true,
      "work_orders.manage_pending_requests": true,
      "assets.create": true, "assets.update": true, "assets.delete": true,
      "locations.create": true, "locations.update": true, "locations.delete": true,
      "reports.create": true, "reports.update": true, "reports.delete": true,
      "attachments.create": true, "attachments.update": true, "attachments.delete": true,
      "checklists.create": true, "checklists.update": true, "checklists.delete": true,
      "maintenance_plans.create": true, "maintenance_plans.update": true, "maintenance_plans.delete": true,
      "users.read": true,
      "access_logs.read": true,
      "categories.create": true, "categories.update": true, "categories.delete": true,
      "sla_policies.create": true, "sla_policies.update": true, "sla_policies.delete": true,
      "sectors.create": true, "sectors.update": true, "sectors.delete": true,
      "service_providers.create": true, "service_providers.update": true, "service_providers.delete": true,
      "customers.create": true, "customers.update": true, "customers.delete": true
    }'::jsonb, 
    true, now());

  -- Insert Técnico group
  INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
  VALUES (gen_random_uuid(), NEW.id, 'Técnico', 
    '{
      "work_orders.read_scope": "assigned",
      "work_orders.create": false,
      "work_orders.update_scope": "assigned",
      "work_orders.delete": false,
      "work_orders.change_status": true,
      "work_orders.reassign": false,
      "work_orders.manage_pending_requests": false,
      "attachments.create": true, "attachments.update": true,
      "checklists.update": true
    }'::jsonb, 
    true, now());

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Reconcile existing Supervisor permission groups to include customers
UPDATE public.permission_groups
SET permissions = permissions || '{
  "customers.create": true,
  "customers.update": true,
  "customers.delete": true
}'::jsonb
WHERE name = 'Supervisor' AND jsonb_typeof(permissions) = 'object';
