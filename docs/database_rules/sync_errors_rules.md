# sync_errors — Database Rules

## 1. RLS Policies

```sql
ALTER TABLE public.sync_errors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own company sync errors"
  ON public.sync_errors FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company sync errors"
  ON public.sync_errors FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());
```

## 2. Triggers

### 2.1 Hard Delete Protection
```sql
CREATE TRIGGER tr_prevent_delete_sync_errors
BEFORE DELETE ON public.sync_errors
FOR EACH ROW
EXECUTE FUNCTION public.prevent_delete();
```
