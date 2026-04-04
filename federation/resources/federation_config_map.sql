-- F25: Federation Config Map (Key-Value-Map für statische Konfigurationen)

CREATE TABLE IF NOT EXISTS federation_config_map (
    config_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key TEXT NOT NULL UNIQUE,
    config_value TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_config_map (config_key, config_value)
VALUES
    ('max_nodes', '10000'),
    ('max_domains', '100'),
    ('max_trust_levels', '10')
ON CONFLICT DO NOTHING;
