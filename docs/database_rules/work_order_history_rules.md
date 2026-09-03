# work_order_history — Database Rules

## 1. RLS Policies

```sql
ALTER TABLE public.work_order_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view work order history of their company"
    ON public.work_order_history
    FOR SELECT
    TO authenticated
    USING (
        company_id = public.get_user_company_id()
        OR public.is_provider_member_of_work_order_id(work_order_id)
    );

CREATE POLICY "Users can insert work order history for their company"
    ON public.work_order_history
    FOR INSERT
    TO authenticated
    WITH CHECK (
        company_id = public.get_user_company_id()
        OR public.is_provider_member_of_work_order_id(work_order_id)
    );
```

## 2. Triggers

### 2.1 Hard Delete Protection
```sql
CREATE TRIGGER tr_prevent_delete_work_order_history
BEFORE DELETE ON public.work_order_history
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();
```
