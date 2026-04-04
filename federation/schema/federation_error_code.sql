-- F87: Schema – Federation Error Codes

CREATE TABLE IF NOT EXISTS federation_error_code (
    error_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    error_code TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
