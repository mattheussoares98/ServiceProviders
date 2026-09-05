# access_logs — Database Rules

## 1. RLS Policies

```sql
ALTER TABLE public.access_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Internal users can view access logs of their company"
    ON public.access_logs
    FOR SELECT
    TO authenticated
    USING (
        company_id = public.get_user_company_id()
    );

CREATE POLICY "Authenticated users can insert access logs for their own company and user id"
    ON public.access_logs
    FOR INSERT
    TO authenticated
    WITH CHECK (
        company_id = public.get_user_company_id()
        AND user_id = auth.uid()
    );
```

## 2. Immutability & Hard Delete Protection

Access logs are append-only. No UPDATE policy is defined.
Hard deletes are prevented with the standard delete prevention trigger:

```sql
CREATE TRIGGER tr_prevent_delete_access_logs
BEFORE DELETE ON public.access_logs
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();
```
