-- F83: Schema – Federation Sync Definitions

CREATE TABLE IF NOT EXISTS federation_sync (
    sync_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sync_key TEXT NOT NULL UNIQUE,
    sync_value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
