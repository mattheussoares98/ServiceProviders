-- Fix has_permission() for the JSONB object permission format.
--
-- 20260825020000_fix_user_profiles_rls_super_admin.sql added the super-admin
-- short-circuit but rewrote the body of has_permission() as:
--
--   RETURN v_permissions ? permission_key;
--
-- On a JSONB *object* the `?` operator tests key EXISTENCE, not the value. So
-- a group spelling a permission out as false --
--
--   {"work_orders.manage_pending_requests": false}
--
-- -- was GRANTED that permission. 20260905191500 creates exactly that shape for
-- the default Técnico group, so technicians in every company seeded since then
-- hold permissions the UI believes they do not.
--
-- That rewrite also dropped the `.read_scope` / `.update_scope` handling added
-- by 20260717000000, so a scope key was tested for existence rather than for
-- being something other than 'none'.
--
-- This restores the 20260717000000 semantics and keeps the super-admin
-- short-circuit.

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
  IF public.is_super_admin() THEN
    RETURN TRUE;
  END IF;

  SELECT
    up.is_admin,
    COALESCE(pg.permissions, '{}'::jsonb)
  INTO
    v_is_admin,
    v_permissions
  FROM public.user_profiles up
  LEFT JOIN public.permission_groups pg ON up.permission_group_id = pg.id
  WHERE up.id = auth.uid();

  -- The admin wildcard. In the legacy array format its presence is the grant;
  -- in the object format the VALUE must be true, so that {"*": false} denies.
  IF COALESCE(v_is_admin, false)
     OR (jsonb_typeof(v_permissions) = 'array' AND v_permissions ? '*')
     OR (jsonb_typeof(v_permissions) = 'object'
         AND COALESCE((v_permissions -> '*') = 'true'::jsonb, false)) THEN
    RETURN TRUE;
  END IF;

  -- Legacy array format: membership is the grant.
  IF jsonb_typeof(v_permissions) = 'array' THEN
    RETURN v_permissions ? permission_key;
  END IF;

  IF jsonb_typeof(v_permissions) = 'object' THEN
    -- Scope keys hold a string ('all' / 'assigned' / 'own' / 'none'), so any
    -- value other than 'none' is a grant.
    IF permission_key LIKE '%.read_scope' OR permission_key LIKE '%.update_scope' THEN
      RETURN COALESCE(
        (v_permissions ->> permission_key) IS NOT NULL
        AND (v_permissions ->> permission_key) <> 'none',
        false
      );
    END IF;

    -- Boolean keys. Compared against the jsonb literal rather than cast with
    -- ::boolean, so that a key holding an unexpected string returns false
    -- instead of raising 22P02 and failing the whole RLS check.
    RETURN COALESCE((v_permissions -> permission_key) = 'true'::jsonb, false);
  END IF;

  RETURN FALSE;
END;
$$;
