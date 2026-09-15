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
    OR (
      public.is_provider_member_of_work_order_id(work_order_id)
      AND public.work_order_accepts_attachments(work_order_id)
    )
  );

CREATE POLICY "Users update own company attachments with permission"
  ON public.attachments FOR UPDATE TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND (
      (
        EXISTS (
          SELECT 1 FROM public.work_orders wo
          WHERE wo.id = attachments.work_order_id
            AND wo.status IN ('completed', 'cancelled', 'pending_conclusion')
        )
        AND public.has_permission('work_orders.manage_pending_requests')
      )
      OR (
        NOT EXISTS (
          SELECT 1 FROM public.work_orders wo
          WHERE wo.id = attachments.work_order_id
            AND wo.status IN ('completed', 'cancelled', 'pending_conclusion')
        )
        AND (
          public.has_permission('attachments.update')
          OR public.has_permission('attachments.delete')
        )
      )
    )
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
  );
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

## Realtime

`20260911170500_publish_attachments_realtime.sql` adds the table to the `supabase_realtime` publication and sets `REPLICA IDENTITY FULL`. `AttachmentsRemoteDataSource.watchAttachmentsRealtime` filters the stream by `work_order_id`, syncing new, updated, and soft-deleted attachments live across devices.

