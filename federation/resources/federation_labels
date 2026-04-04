-- F39: Federation Labels (Tags für Nodes, Events, Domains)

CREATE TABLE IF NOT EXISTS federation_label (
    label_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    label_key TEXT NOT NULL UNIQUE,
    label_value TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_label (label_key, label_value)
VALUES
    ('tier', 'core'),
    ('tier', 'edge'),
    ('environment', 'production'),
    ('environment', 'staging')
ON CONFLICT DO NOTHING;
