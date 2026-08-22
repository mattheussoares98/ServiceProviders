# User Device Tokens Policies

```sql
-- Users can only read/write/delete their own device token records (keyed by user_id = auth.uid())
CREATE POLICY "Users can read own device tokens"
  ON public.user_device_tokens FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own device tokens"
  ON public.user_device_tokens FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own device tokens"
  ON public.user_device_tokens FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own device tokens"
  ON public.user_device_tokens FOR DELETE TO authenticated
  USING (auth.uid() = user_id);
```

> **Note:** Device tokens are tied directly to `auth.users(id)` so internal users, service providers, and dual-identity users can register tokens. Hard deletes occur when a token is deregistered or user is deleted.
