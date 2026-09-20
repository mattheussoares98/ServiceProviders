-- Enforce non-empty name and email for service provider entities
ALTER TABLE service_provider_companies
  ADD CONSTRAINT chk_service_provider_companies_name_not_empty
  CHECK (length(trim(name)) > 0);

ALTER TABLE service_provider_invitations
  ADD CONSTRAINT chk_service_provider_invitations_email_not_empty
  CHECK (length(trim(email)) > 0);

ALTER TABLE service_provider_profiles
  ADD CONSTRAINT chk_service_provider_profiles_name_not_empty
  CHECK (length(trim(name)) > 0);

ALTER TABLE service_provider_profiles
  ADD CONSTRAINT chk_service_provider_profiles_email_not_empty
  CHECK (length(trim(email)) > 0);
