-- ==========================================
-- Company Parameters Table
-- ==========================================
CREATE TABLE IF NOT EXISTS public.company_parameters (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  -- Offline governance limits
  max_offline_duration_hours INTEGER NOT NULL DEFAULT 2 CONSTRAINT chk_max_offline_duration_hours CHECK (max_offline_duration_hours > 0),
  max_offline_pending_requests INTEGER NOT NULL DEFAULT 10 CONSTRAINT chk_max_offline_pending_requests CHECK (max_offline_pending_requests > 0),
  offline_alert_throttle_frequency INTEGER NOT NULL DEFAULT 3 CONSTRAINT chk_offline_alert_throttle_frequency CHECK (offline_alert_throttle_frequency > 0),
  -- Attachment size limits (stored in MB)
  max_image_size_mb INTEGER NOT NULL DEFAULT 20 CONSTRAINT chk_max_image_size_mb CHECK (max_image_size_mb > 0),
  max_video_size_mb INTEGER NOT NULL DEFAULT 500 CONSTRAINT chk_max_video_size_mb CHECK (max_video_size_mb > 0),
  max_pdf_size_mb INTEGER NOT NULL DEFAULT 10 CONSTRAINT chk_max_pdf_size_mb CHECK (max_pdf_size_mb > 0),
  max_document_size_mb INTEGER NOT NULL DEFAULT 5 CONSTRAINT chk_max_document_size_mb CHECK (max_document_size_mb > 0),
  sandbox_quota_mb INTEGER NOT NULL DEFAULT 1024 CONSTRAINT chk_sandbox_quota_mb CHECK (sandbox_quota_mb > 0),
  -- System governance
  max_sync_attempts INTEGER NOT NULL DEFAULT 3 CONSTRAINT chk_max_sync_attempts CHECK (max_sync_attempts > 0),
  invite_expiry_hours INTEGER NOT NULL DEFAULT 24 CONSTRAINT chk_invite_expiry_hours CHECK (invite_expiry_hours > 0),
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL,
  CONSTRAINT uq_company_parameters_company_id UNIQUE (company_id)
);

ALTER TABLE public.company_parameters ENABLE ROW LEVEL SECURITY;

-- RLS: Read company parameters
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

-- RLS: Insert company parameters
CREATE POLICY "Company admins insert own company parameters"
  ON public.company_parameters FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
  );

-- RLS: Update company parameters
CREATE POLICY "Company admins update own company parameters"
  ON public.company_parameters FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
  );

-- Soft delete protection
CREATE TRIGGER tr_prevent_delete_company_parameters
BEFORE DELETE ON public.company_parameters
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();

CREATE INDEX IF NOT EXISTS idx_company_parameters_company_id ON public.company_parameters(company_id);

-- Auto-provision parameters for new companies
CREATE OR REPLACE FUNCTION public.handle_new_company_parameters()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.company_parameters (company_id)
  VALUES (NEW.id)
  ON CONFLICT (company_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_create_default_parameters_for_new_company ON public.companies;

CREATE TRIGGER tr_create_default_parameters_for_new_company
AFTER INSERT ON public.companies
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_company_parameters();

-- Backfill default parameter rows for existing companies
INSERT INTO public.company_parameters (company_id)
SELECT id FROM public.companies
ON CONFLICT (company_id) DO NOTHING;
