-- Fix has_permission helper mapping for work orders
CREATE OR REPLACE FUNCTION public.has_permission(permission_key TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  v_is_admin BOOLEAN;
  v_permissions JSONB;
BEGIN
  -- Get user profile details
  SELECT 
    up.is_admin,
    COALESCE(pg.permissions, '{}'::jsonb)
  INTO 
    v_is_admin,
    v_permissions
  FROM public.user_profiles up
  LEFT JOIN public.permission_groups pg ON up.permission_group_id = pg.id
  WHERE up.id = auth.uid();

  -- Admin has all permissions
  IF COALESCE(v_is_admin, false) 
     OR (jsonb_typeof(v_permissions) = 'array' AND v_permissions ? '*') 
     OR (jsonb_typeof(v_permissions) = 'object' AND COALESCE((v_permissions ->> '*')::boolean, false)) THEN
    RETURN TRUE;
  END IF;

  -- Support old array format
  IF jsonb_typeof(v_permissions) = 'array' THEN
    RETURN v_permissions ? permission_key;
  -- Support new flat object format
  ELSIF jsonb_typeof(v_permissions) = 'object' THEN
    -- If it's a scope value (e.g. read_scope, update_scope), check if it's not 'none'
    IF permission_key LIKE '%.read_scope' OR permission_key LIKE '%.update_scope' THEN
      RETURN COALESCE((v_permissions ->> permission_key) IS NOT NULL AND (v_permissions ->> permission_key) <> 'none', false);
    ELSIF permission_key = 'work_orders.read' THEN
      RETURN COALESCE((v_permissions ->> 'work_orders.read_scope') IS NOT NULL AND (v_permissions ->> 'work_orders.read_scope') <> 'none', false);
    ELSIF permission_key = 'work_orders.update' THEN
      RETURN COALESCE((v_permissions ->> 'work_orders.update_scope') IS NOT NULL AND (v_permissions ->> 'work_orders.update_scope') <> 'none', false);
    ELSE
      -- Handle fallback lookup (if key is boolean)
      RETURN COALESCE((v_permissions -> permission_key)::boolean, false);
    END IF;
  END IF;

  RETURN FALSE;
END;
$$;

-- Create service provider invitations table
CREATE TABLE IF NOT EXISTS public.service_provider_invitations (
  id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL,
  service_provider_company_id UUID NOT NULL REFERENCES public.service_provider_companies(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  accepted_at TIMESTAMP WITH TIME ZONE NULL,
  CONSTRAINT unique_pending_sp_invitation UNIQUE (email, service_provider_company_id)
);

ALTER TABLE public.service_provider_invitations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Company users read and manage service provider invitations" ON public.service_provider_invitations;
CREATE POLICY "Company users read and manage service provider invitations"
  ON public.service_provider_invitations FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.service_provider_companies spc
      WHERE spc.id = service_provider_company_id
        AND spc.company_id = public.get_user_company_id()
    )
  );

-- Function/Trigger to auto link profiles when user registers/logs in
CREATE OR REPLACE FUNCTION public.handle_service_provider_link()
RETURNS TRIGGER AS $$
DECLARE
  v_invitation RECORD;
BEGIN
  -- Search for any invitation matching the new user's email
  FOR v_invitation IN
    SELECT * FROM public.service_provider_invitations
    WHERE email = NEW.email AND accepted_at IS NULL
  LOOP
    -- Check if a service provider profile already exists for this email and company
    IF EXISTS (
      SELECT 1 FROM public.service_provider_profiles
      WHERE email = NEW.email AND service_provider_company_id = v_invitation.service_provider_company_id
    ) THEN
      UPDATE public.service_provider_profiles
      SET auth_user_id = NEW.id
      WHERE email = NEW.email AND service_provider_company_id = v_invitation.service_provider_company_id;
    ELSE
      -- Insert a new profile with the link
      INSERT INTO public.service_provider_profiles (auth_user_id, service_provider_company_id, name, email, is_active)
      VALUES (NEW.id, v_invitation.service_provider_company_id, COALESCE(NEW.raw_user_meta_data->>'name', NEW.email), NEW.email, true);
    END IF;

    -- Mark invitation as accepted
    UPDATE public.service_provider_invitations
    SET accepted_at = now()
    WHERE id = v_invitation.id;
  END LOOP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users when a new user record is created (invite accepted or signup)
DROP TRIGGER IF EXISTS tr_auth_user_created_sp_link ON auth.users;
CREATE TRIGGER tr_auth_user_created_sp_link
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_service_provider_link();

-- Create helper function to create or update invitation
CREATE OR REPLACE FUNCTION public.create_service_provider_invitation(p_email TEXT, p_service_provider_company_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_invitation_id UUID;
  v_auth_user_id UUID;
BEGIN
  -- Insert into invitations table
  INSERT INTO public.service_provider_invitations (email, service_provider_company_id)
  VALUES (p_email, p_service_provider_company_id)
  ON CONFLICT (email, service_provider_company_id) DO UPDATE
    SET created_at = now()
  RETURNING id INTO v_invitation_id;

  -- Check if user already exists in auth.users
  SELECT id INTO v_auth_user_id FROM auth.users WHERE email = p_email LIMIT 1;

  IF v_auth_user_id IS NOT NULL THEN
    -- User exists, link them directly
    IF EXISTS (
      SELECT 1 FROM public.service_provider_profiles
      WHERE email = p_email AND service_provider_company_id = p_service_provider_company_id
    ) THEN
      UPDATE public.service_provider_profiles
      SET auth_user_id = v_auth_user_id
      WHERE email = p_email AND service_provider_company_id = p_service_provider_company_id;
    ELSE
      INSERT INTO public.service_provider_profiles (auth_user_id, service_provider_company_id, name, email, is_active)
      VALUES (v_auth_user_id, p_service_provider_company_id, p_email, p_email, true);
    END IF;

    -- Mark invitation as accepted
    UPDATE public.service_provider_invitations
    SET accepted_at = now()
    WHERE id = v_invitation_id;
  END IF;

  RETURN v_invitation_id;
END;
$$;
