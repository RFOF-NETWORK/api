-- F81: Schema – Federation Region

CREATE TABLE IF NOT EXISTS federation_region (
    region_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    region_key TEXT NOT NULL UNIQUE,
    region_label TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
