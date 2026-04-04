-- F72: Schema – Federation Domain

CREATE TABLE IF NOT EXISTS federation_domain (
    domain_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
