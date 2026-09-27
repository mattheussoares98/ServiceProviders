# Customers Policies

```sql
-- SELECT: company users OR service providers linked to that company
CREATE POLICY "Users read own company customers"
  ON public.customers FOR SELECT TO authenticated
  USING (
    company_id = public.get_user_company_id()
    OR public.is_provider_of_company(company_id)
  );

-- INSERT: requires customers.create
CREATE POLICY "Users insert own company customers with permission"
  ON public.customers FOR INSERT TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('customers.create')
  );

-- UPDATE: requires customers.update or customers.delete
CREATE POLICY "Users update own company customers with permission"
  ON public.customers FOR UPDATE TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND (
      public.has_permission('customers.update')
      OR public.has_permission('customers.delete')
    )
  )
  WITH CHECK (
    company_id = public.get_user_company_id()
  );
```

## Triggers

```sql
CREATE TRIGGER tr_prevent_delete_customers
BEFORE DELETE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.prevent_delete();

-- Blocks soft-delete when active work orders reference this customer (20260927194500)
CREATE TRIGGER tr_prevent_delete_customers_with_relations
  BEFORE UPDATE ON public.customers FOR EACH ROW
  EXECUTE FUNCTION public.check_customer_before_delete();

-- Generic audit logging
CREATE TRIGGER tr_audit_customers
  AFTER INSERT OR UPDATE ON public.customers FOR EACH ROW
  EXECUTE FUNCTION public.handle_generic_audit();
```

## Realtime Publication

Included in `supabase_realtime` publication with `REPLICA IDENTITY FULL` (migration `20260927194500_create_customers_and_adapt_work_orders_assets.sql`).
