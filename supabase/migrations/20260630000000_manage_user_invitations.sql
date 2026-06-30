-- Modify prevent_delete to allow deletions of unconfirmed users (pending invitations)
CREATE OR REPLACE FUNCTION public.prevent_delete()
RETURNS TRIGGER AS $$
BEGIN
  -- If the user exists in auth.users and is confirmed, block deletion
  IF EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = OLD.id AND confirmed_at IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'Hard deletes are disabled. Use soft delete by setting deleted_at instead.';
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get pending invitations for the current user's company
CREATE OR REPLACE FUNCTION public.get_pending_invitations()
RETURNS TABLE (
  id UUID,
  email TEXT,
  invited_at TIMESTAMPTZ,
  company_id UUID,
  permission_group_id UUID,
  name TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.email::TEXT,
    u.invited_at,
    (u.raw_user_meta_data->>'company_id')::UUID,
    (u.raw_user_meta_data->>'permission_group_id')::UUID,
    (u.raw_user_meta_data->>'name')::TEXT
  FROM auth.users u
  WHERE 
    (u.raw_user_meta_data->>'company_id')::UUID = public.get_user_company_id()
    AND u.invited_at IS NOT NULL 
    AND u.confirmed_at IS NULL;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_pending_invitations() TO authenticated;

-- Function to revoke (delete) a pending invitation
CREATE OR REPLACE FUNCTION public.revoke_invitation(invitation_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  caller_company_id UUID;
BEGIN
  caller_company_id := public.get_user_company_id();
  
  -- Delete the user from auth.users (cascades to public.user_profiles)
  -- only if they belong to the caller's company and are not confirmed yet.
  DELETE FROM auth.users
  WHERE id = invitation_id
    AND (raw_user_meta_data->>'company_id')::UUID = caller_company_id
    AND confirmed_at IS NULL;
END;
$$;

GRANT EXECUTE ON FUNCTION public.revoke_invitation(UUID) TO authenticated;
