-- ==========================================
-- User Configurations Table
-- ==========================================
CREATE TABLE IF NOT EXISTS public.user_configurations (
  user_id UUID NOT NULL PRIMARY KEY REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  push_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  theme_mode VARCHAR(20) NOT NULL DEFAULT 'system',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.user_configurations ENABLE ROW LEVEL SECURITY;

-- Select configurations: users can read their own configurations
CREATE POLICY "Users can read own configurations"
  ON public.user_configurations FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Insert/Upsert configurations: users can insert/update their own configurations
CREATE POLICY "Users can insert own configurations"
  ON public.user_configurations FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own configurations"
  ON public.user_configurations FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);
