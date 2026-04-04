-- Constraints
ALTER TABLE docs_migrations
    ADD CONSTRAINT docs_migration_key_not_empty CHECK (migration_key <> '');
