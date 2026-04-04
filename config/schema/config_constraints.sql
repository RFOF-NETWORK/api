-- Constraints
ALTER TABLE config_env
    ADD CONSTRAINT config_env_value_not_empty CHECK (value <> '');
