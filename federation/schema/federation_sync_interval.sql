-- F90: Schema – Federation Sync Intervals

CREATE TABLE IF NOT EXISTS federation_sync_interval (
    interval_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    interval_key TEXT NOT NULL UNIQUE,
    interval_seconds INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
