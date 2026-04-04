-- Initialmigration
INSERT INTO docs_migrations (migration_key)
VALUES ('docs_init')
ON CONFLICT DO NOTHING;
