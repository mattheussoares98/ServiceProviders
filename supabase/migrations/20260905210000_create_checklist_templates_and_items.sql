-- ==============================================================================
-- Migration: Create Checklist Templates & Checklist Items Tables with Realtime
-- ==============================================================================

-- 1. Create Checklist Templates Table
CREATE TABLE IF NOT EXISTS public.checklist_templates (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(1000) NULL,
  category_id UUID NULL REFERENCES public.categories(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);

ALTER TABLE public.checklist_templates ENABLE ROW LEVEL SECURITY;

-- Read checklist_templates: company users or service providers associated with company
CREATE POLICY "Users read own company checklist templates"
  ON public.checklist_templates FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.service_provider_profiles spp
      JOIN public.service_provider_companies spc ON spp.service_provider_company_id = spc.id
      WHERE spp.auth_user_id = auth.uid() AND spc.company_id = public.checklist_templates.company_id
    )
  );

-- Insert checklist_templates: company users with checklists.create permission
CREATE POLICY "Company users insert own company checklist templates with permission"
  ON public.checklist_templates FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('checklists.create')
  );

-- Update checklist_templates: company users with checklists.update permission
CREATE POLICY "Company users update own company checklist templates with permission"
  ON public.checklist_templates FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('checklists.update')
  );

CREATE TRIGGER tr_prevent_delete_checklist_templates
BEFORE DELETE ON public.checklist_templates
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX IF NOT EXISTS idx_checklist_templates_company ON public.checklist_templates(company_id);
CREATE INDEX IF NOT EXISTS idx_checklist_templates_category ON public.checklist_templates(category_id);

-- 2. Create Checklist Items Table
CREATE TABLE IF NOT EXISTS public.checklist_items (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID NOT NULL REFERENCES public.checklist_templates(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  label VARCHAR(500) NOT NULL,
  type VARCHAR(50) NOT NULL DEFAULT 'boolean',
  is_required BOOLEAN NOT NULL DEFAULT false,
  options JSONB NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);

ALTER TABLE public.checklist_items ENABLE ROW LEVEL SECURITY;

-- Read checklist_items: company users or service providers associated with company
CREATE POLICY "Users read own company checklist items"
  ON public.checklist_items FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.service_provider_profiles spp
      JOIN public.service_provider_companies spc ON spp.service_provider_company_id = spc.id
      WHERE spp.auth_user_id = auth.uid() AND spc.company_id = public.checklist_items.company_id
    )
  );

-- Insert checklist_items: company users with checklists.create/update permission
CREATE POLICY "Company users insert own company checklist items with permission"
  ON public.checklist_items FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND (public.has_permission('checklists.create') OR public.has_permission('checklists.update'))
  );

-- Update checklist_items: company users with checklists.update permission
CREATE POLICY "Company users update own company checklist items with permission"
  ON public.checklist_items FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('checklists.update')
  );

CREATE TRIGGER tr_prevent_delete_checklist_items
BEFORE DELETE ON public.checklist_items
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX IF NOT EXISTS idx_checklist_items_template ON public.checklist_items(template_id);
CREATE INDEX IF NOT EXISTS idx_checklist_items_company ON public.checklist_items(company_id);

-- 3. Set REPLICA IDENTITY FULL for realtime delete / update streaming
ALTER TABLE public.checklist_templates REPLICA IDENTITY FULL;
ALTER TABLE public.checklist_items REPLICA IDENTITY FULL;

-- 4. Enable Realtime Publications
ALTER PUBLICATION supabase_realtime ADD TABLE public.checklist_templates, public.checklist_items;
