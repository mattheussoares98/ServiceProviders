# company_parameters — Database Rules

## 1. RLS Policies

```sql
ALTER TABLE public.company_parameters ENABLE ROW LEVEL SECURITY;

-- Read company parameters
CREATE POLICY "Users read own company parameters"
  ON public.company_parameters FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR EXISTS (
      SELECT 1 FROM public.service_provider_profiles spp
      JOIN public.service_provider_companies spc ON spp.service_provider_company_id = spc.id
      WHERE spp.auth_user_id = auth.uid() AND spc.company_id = public.company_parameters.company_id
    )
  );

-- Insert company parameters
CREATE POLICY "Company admins insert own company parameters"
  ON public.company_parameters FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
  );

-- Update company parameters
CREATE POLICY "Company admins update own company parameters"
  ON public.company_parameters FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
  );
```

## 2. Triggers & Automation

### 2.1 Hard Delete Protection
```sql
CREATE TRIGGER tr_prevent_delete_company_parameters
BEFORE DELETE ON public.company_parameters
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();
```

### 2.2 Auto-provision Parameters for New Companies
When a new company is created, default parameters are automatically inserted:
```sql
CREATE OR REPLACE FUNCTION public.handle_new_company_parameters()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.company_parameters (company_id)
  VALUES (NEW.id)
  ON CONFLICT (company_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER tr_create_default_parameters_for_new_company
AFTER INSERT ON public.companies
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_company_parameters();
```
