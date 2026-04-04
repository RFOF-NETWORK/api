-- F96: Schema – Federation Integrity Checks

CREATE TABLE IF NOT EXISTS federation_integrity (
    integrity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    check_key TEXT NOT NULL UNIQUE,
    check_definition JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
