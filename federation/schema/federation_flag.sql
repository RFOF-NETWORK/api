-- F80: Schema – Federation Flags (Feature Flags)

CREATE TABLE IF NOT EXISTS federation_flag (
    flag_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flag_key TEXT NOT NULL UNIQUE,
    flag_enabled BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
