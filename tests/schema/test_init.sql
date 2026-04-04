-- Initialmigration
INSERT INTO test_migrations (migration_key)
VALUES ('tests_init')
ON CONFLICT DO NOTHING;
