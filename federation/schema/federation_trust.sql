-- F71: Schema – Federation Trust Levels

CREATE TABLE IF NOT EXISTS federation_trust (
    trust_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    federation_id UUID NOT NULL,
    trust_level INT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
