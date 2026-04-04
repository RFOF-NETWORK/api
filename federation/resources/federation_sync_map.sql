-- F33: Sync Map für Federation (welche Daten synchronisiert werden)

CREATE TABLE IF NOT EXISTS federation_sync_map (
    sync_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sync_key TEXT NOT NULL UNIQUE,
    sync_value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_sync_map (sync_key, sync_value)
VALUES
    ('sync_nodes', '{"enabled":true}'),
    ('sync_subscriptions', '{"enabled":true}'),
    ('sync_trust_levels', '{"enabled":true}')
ON CONFLICT DO NOTHING;
