-- Migration Registry
CREATE TABLE IF NOT EXISTS test_migrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    migration_key TEXT UNIQUE NOT NULL,
    applied_at TIMESTAMPTZ DEFAULT now()
);
