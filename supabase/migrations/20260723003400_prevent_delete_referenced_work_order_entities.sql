-- 1. SLA Policies check
CREATE OR REPLACE FUNCTION public.check_sla_policy_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    IF EXISTS (
      SELECT 1 
      FROM public.work_orders 
      WHERE sla_policy_id = OLD.id 
        AND status != 'completed' 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir esta política de SLA porque ela está associada a ordens de serviço ativas.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_prevent_delete_sla_policies_with_relations
  BEFORE UPDATE ON public.sla_policies
  FOR EACH ROW
  EXECUTE FUNCTION public.check_sla_policy_before_delete();

-- 2. User Profiles check
CREATE OR REPLACE FUNCTION public.check_user_profile_before_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL) THEN
    IF EXISTS (
      SELECT 1 
      FROM public.work_orders 
      WHERE assigned_to_id = OLD.id 
        AND status != 'completed' 
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION 'Não é possível excluir este usuário porque ele está atribuído a ordens de serviço ativas.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_prevent_delete_user_profiles_with_relations
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.check_user_profile_before_delete();
