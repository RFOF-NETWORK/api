-- F29: Federation Metadata (statische Metadaten für Systembeschreibung)

CREATE TABLE IF NOT EXISTS federation_metadata (
    metadata_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meta_key TEXT NOT NULL UNIQUE,
    meta_value TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_metadata (meta_key, meta_value)
VALUES
    ('system_name', 'RFOF Federation Layer'),
    ('version', '1.0.0'),
    ('maintainer', 'GPCB / RFOF Core Systems')
ON CONFLICT DO NOTHING;
