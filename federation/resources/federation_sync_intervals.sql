-- F37: Sync Interval Definitionen

CREATE TABLE IF NOT EXISTS federation_sync_interval (
    interval_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    interval_key TEXT NOT NULL UNIQUE,
    interval_seconds INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_sync_interval (interval_key, interval_seconds)
VALUES
    ('node_sync', 60),
    ('trust_sync', 120),
    ('subscription_sync', 180)
ON CONFLICT DO NOTHING;
