-- Initialmigration
INSERT INTO config_migrations (migration_key)
VALUES ('config_init')
ON CONFLICT DO NOTHING;
