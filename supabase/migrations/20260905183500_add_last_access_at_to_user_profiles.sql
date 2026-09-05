-- Migration: add last_access_at to user_profiles and sync via access_logs trigger
-- Description: Adds last_access_at column to user_profiles and automatically updates it on access log insertion

ALTER TABLE public.user_profiles
ADD COLUMN IF NOT EXISTS last_access_at TIMESTAMPTZ;

-- Function to update user_profiles.last_access_at on new access_log
CREATE OR REPLACE FUNCTION public.handle_access_log_user_last_access()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.user_profiles
    SET last_access_at = NEW.created_at
    WHERE id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on access_logs insert
DROP TRIGGER IF EXISTS tr_update_user_last_access ON public.access_logs;
CREATE TRIGGER tr_update_user_last_access
    AFTER INSERT ON public.access_logs
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_access_log_user_last_access();
