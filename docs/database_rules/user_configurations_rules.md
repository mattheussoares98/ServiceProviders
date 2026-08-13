# User Configurations Policies

```sql
-- Users can only read/write their own configuration row (keyed by user_id = auth.uid())
CREATE POLICY "Users can read own configurations"
  ON public.user_configurations FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own configurations"
  ON public.user_configurations FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own configurations"
  ON public.user_configurations FOR UPDATE TO authenticated
  USING (auth.uid() = user_id);
```

> **Note:** No `deleted_at` column — this table is user-owned config with no soft-delete requirement. No hard-delete prevention trigger applied.
