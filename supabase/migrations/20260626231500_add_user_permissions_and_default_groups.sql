-- Add permissions column to user_profiles table if it does not exist
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS permissions jsonb NOT NULL DEFAULT '{}'::jsonb;

-- Seed default groups for the existing company
INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
VALUES 
  (gen_random_uuid(), 'a0e406c4-1926-44cd-a8ee-034b519147b1', 'Supervisor', 
   '["work_orders.create", "work_orders.read", "work_orders.update", "work_orders.delete", "assets.create", "assets.read", "assets.update", "assets.delete", "locations.create", "locations.read", "locations.update", "locations.delete", "reports.create", "reports.read", "reports.update", "reports.delete", "attachments.create", "attachments.read", "attachments.update", "attachments.delete", "checklists.create", "checklists.read", "checklists.update", "checklists.delete", "maintenance_plans.create", "maintenance_plans.read", "maintenance_plans.update", "maintenance_plans.delete", "users.read", "categories.create", "categories.read", "categories.update", "categories.delete"]'::jsonb, 
   true, now()),
  (gen_random_uuid(), 'a0e406c4-1926-44cd-a8ee-034b519147b1', 'Técnico', 
   '["work_orders.read", "work_orders.update", "assets.read", "locations.read", "attachments.create", "attachments.read", "attachments.update", "checklists.read", "checklists.update", "categories.read"]'::jsonb, 
   true, now())
ON CONFLICT DO NOTHING;

-- Create the trigger function for automating default groups on new company insertion
CREATE OR REPLACE FUNCTION public.handle_new_company()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert Administrador group
  INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
  VALUES (gen_random_uuid(), NEW.id, 'Administrador', '["*"]'::jsonb, true, now());

  -- Insert Supervisor group
  INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
  VALUES (gen_random_uuid(), NEW.id, 'Supervisor', 
    '["work_orders.create", "work_orders.read", "work_orders.update", "work_orders.delete", "assets.create", "assets.read", "assets.update", "assets.delete", "locations.create", "locations.read", "locations.update", "locations.delete", "reports.create", "reports.read", "reports.update", "reports.delete", "attachments.create", "attachments.read", "attachments.update", "attachments.delete", "checklists.create", "checklists.read", "checklists.update", "checklists.delete", "maintenance_plans.create", "maintenance_plans.read", "maintenance_plans.update", "maintenance_plans.delete", "users.read", "categories.create", "categories.read", "categories.update", "categories.delete"]'::jsonb, 
    true, now());

  -- Insert Técnico group
  INSERT INTO public.permission_groups (id, company_id, name, permissions, is_default, created_at)
  VALUES (gen_random_uuid(), NEW.id, 'Técnico', 
    '["work_orders.read", "work_orders.update", "assets.read", "locations.read", "attachments.create", "attachments.read", "attachments.update", "checklists.read", "checklists.update", "categories.read"]'::jsonb, 
    true, now());

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop the trigger if it already exists to prevent duplicate trigger errors
DROP TRIGGER IF EXISTS tr_create_default_groups_for_new_company ON public.companies;

-- Create the trigger
CREATE TRIGGER tr_create_default_groups_for_new_company
AFTER INSERT ON public.companies
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_company();
