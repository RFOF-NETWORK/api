-- F26: Federation Limits (harte Systemgrenzen)

CREATE TABLE IF NOT EXISTS federation_limit (
    limit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    limit_key TEXT NOT NULL UNIQUE,
    limit_value INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_limit (limit_key, limit_value)
VALUES
    ('max_events_per_minute', 10000),
    ('max_replay_batch', 5000),
    ('max_subscriptions_per_node', 1000)
ON CONFLICT DO NOTHING;
