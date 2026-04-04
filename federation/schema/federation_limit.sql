-- F77: Schema – Federation Limits (Systemgrenzen)

CREATE TABLE IF NOT EXISTS federation_limit (
    limit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    limit_key TEXT NOT NULL UNIQUE,
    limit_value INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
