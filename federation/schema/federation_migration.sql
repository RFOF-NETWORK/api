-- F95: Schema – Federation Migration Registry

CREATE TABLE IF NOT EXISTS federation_migration (
    migration_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    migration_key TEXT NOT NULL UNIQUE,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
