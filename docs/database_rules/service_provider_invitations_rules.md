# Service Provider Invitations Policies

```sql
-- ALL: company users owning the SP company (read + manage)
CREATE POLICY "Company users read and manage service provider invitations"
  ON public.service_provider_invitations FOR ALL TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.service_provider_companies spc
      WHERE spc.id = service_provider_company_id AND spc.company_id = public.get_user_company_id())
  );
```

## Helper Functions

| Function | Description |
|---|---|
| `create_service_provider_invitation(email, company_id, token?, days?)` | Upserts invitation, validates email uniqueness, auto-links existing `auth.users` |
| `accept_service_provider_invitation(email)` | Marks invitation `accepted`, syncs `service_provider_companies.invitation_status` |
| `delete_service_provider_invitation(id)` | Deletes invitation, syncs `invitation_status` on company from most recent remaining |
| `validate_sp_email_uniqueness(email, company_id)` | Alias used in later migrations; calls `check_sp_email_availability` |

## Triggers

```sql
-- Auto-link SP profiles when a new auth.users row is created (invite accepted or signup)
CREATE TRIGGER tr_auth_user_created_sp_link
  AFTER INSERT ON auth.users FOR EACH ROW
  EXECUTE FUNCTION public.handle_service_provider_link();
```
