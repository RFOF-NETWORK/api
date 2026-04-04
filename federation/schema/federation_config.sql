-- F76: Schema – Federation Config (Key-Value Konfigurationen)

CREATE TABLE IF NOT EXISTS federation_config (
    config_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key TEXT NOT NULL UNIQUE,
    config_value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
