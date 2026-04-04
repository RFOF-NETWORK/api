-- Initialmigration
INSERT INTO script_migrations (migration_key)
VALUES ('scripts_init')
ON CONFLICT DO NOTHING;
