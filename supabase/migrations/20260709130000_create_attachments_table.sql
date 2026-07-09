CREATE TABLE public.attachments (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  work_order_id UUID NOT NULL REFERENCES public.work_orders(id) ON DELETE CASCADE,
  uploaded_by_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_type VARCHAR(50) NOT NULL,
  local_path VARCHAR(1000) NULL,
  remote_url VARCHAR(2083) NULL,
  file_size_bytes BIGINT NULL,
  is_compressed BOOLEAN NOT NULL DEFAULT FALSE,
  upload_status VARCHAR(50) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);

ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own company attachments with permission"
  ON public.attachments FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('attachments.read')
  );

CREATE POLICY "Users insert own company attachments with permission"
  ON public.attachments FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('attachments.create')
  );

CREATE POLICY "Users update own company attachments with permission"
  ON public.attachments FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('attachments.update')
  );

CREATE TRIGGER tr_prevent_delete_attachments
BEFORE DELETE ON public.attachments
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX idx_attachments_company ON public.attachments(company_id);
CREATE INDEX idx_attachments_work_order ON public.attachments(work_order_id);
CREATE INDEX idx_attachments_uploaded_by ON public.attachments(uploaded_by_id);
