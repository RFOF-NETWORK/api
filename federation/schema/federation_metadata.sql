-- F88: Schema – Federation Metadata

CREATE TABLE IF NOT EXISTS federation_metadata (
    metadata_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meta_key TEXT NOT NULL UNIQUE,
    meta_value TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
