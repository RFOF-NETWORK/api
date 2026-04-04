-- Initialisierung
INSERT INTO shared_migrations (migration_key)
VALUES ('shared_init')
ON CONFLICT DO NOTHING;
