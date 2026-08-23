CREATE TABLE public.sync_errors (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  entity_type VARCHAR(50) NOT NULL,
  entity_id VARCHAR(100) NOT NULL,
  operation VARCHAR(50) NOT NULL,
  payload JSONB NULL,
  error_type VARCHAR(100) NOT NULL,
  error_message TEXT NOT NULL,
  attempts INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);

ALTER TABLE public.sync_errors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own company sync errors"
  ON public.sync_errors FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company sync errors"
  ON public.sync_errors FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE TRIGGER tr_prevent_delete_sync_errors
BEFORE DELETE ON public.sync_errors
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX idx_sync_errors_company ON public.sync_errors(company_id);
CREATE INDEX idx_sync_errors_user ON public.sync_errors(user_id);
CREATE INDEX idx_sync_errors_entity ON public.sync_errors(entity_type, entity_id);
CREATE INDEX idx_sync_errors_created_at ON public.sync_errors(created_at DESC);
