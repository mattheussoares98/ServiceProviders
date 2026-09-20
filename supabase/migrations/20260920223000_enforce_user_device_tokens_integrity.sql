-- Enforce non-empty device_token and platform on user_device_tokens
ALTER TABLE user_device_tokens
  ADD CONSTRAINT chk_user_device_tokens_device_token_not_empty
  CHECK (length(trim(device_token)) > 0);

ALTER TABLE user_device_tokens
  ADD CONSTRAINT chk_user_device_tokens_platform_not_empty
  CHECK (length(trim(platform)) > 0);
