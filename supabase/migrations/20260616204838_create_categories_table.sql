CREATE TABLE public.categories (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(500) NULL,
  color VARCHAR(50) NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL,
  CONSTRAINT unique_category_name_per_company UNIQUE (company_id, name)
);

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own company categories"
  ON public.categories FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company categories"
  ON public.categories FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company categories"
  ON public.categories FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE TRIGGER tr_prevent_delete_categories
BEFORE DELETE ON public.categories
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

ALTER TABLE public.assets
ADD CONSTRAINT assets_category_id_fkey
FOREIGN KEY (category_id) REFERENCES public.categories(id)
ON DELETE SET NULL;
