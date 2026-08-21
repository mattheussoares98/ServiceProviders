# Attachments Table Policies

```sql
-- SELECT / INSERT / UPDATE: company users with respective permission, plus provider access on assigned work orders
CREATE POLICY "Users read own company attachments with permission"
  ON public.attachments FOR SELECT TO authenticated
  USING (
    (company_id = public.get_user_company_id() AND public.has_permission('attachments.read'))
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );

CREATE POLICY "Users insert own company attachments with permission"
  ON public.attachments FOR INSERT TO authenticated
  WITH CHECK (
    (company_id = public.get_user_company_id() AND public.has_permission('attachments.create'))
    OR public.is_provider_member_of_work_order_id(work_order_id)
  );

CREATE POLICY "Users update own company attachments with permission"
  ON public.attachments FOR UPDATE TO authenticated
  USING (company_id = public.get_user_company_id() AND public.has_permission('attachments.update'));
```

## Triggers

```sql
-- Hard delete prevention
CREATE TRIGGER tr_prevent_delete_attachments
BEFORE DELETE ON public.attachments FOR EACH ROW EXECUTE FUNCTION public.prevent_delete();

-- Cascade soft-delete from work_orders → attachments
CREATE TRIGGER tr_work_order_soft_delete
  AFTER UPDATE OF deleted_at ON public.work_orders
  FOR EACH ROW EXECUTE FUNCTION public.handle_work_order_soft_delete();
```
