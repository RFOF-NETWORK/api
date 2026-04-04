-- Constraints
ALTER TABLE script_registry
    ADD CONSTRAINT script_name_not_empty CHECK (name <> '');
