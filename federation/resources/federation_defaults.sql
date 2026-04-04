-- F23: Default-Konfigurationen für Federation

CREATE TABLE IF NOT EXISTS federation_default (
    default_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL UNIQUE,
    value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_default (key, value)
VALUES
    ('default_trust_level', '{"value": 80}'),
    ('default_domain', '{"value": "core"}'),
    ('default_node_type', '{"value": "root"}')
ON CONFLICT DO NOTHING;
