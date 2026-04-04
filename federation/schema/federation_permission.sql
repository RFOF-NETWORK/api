-- F84: Schema – Federation Permissions

CREATE TABLE IF NOT EXISTS federation_permission (
    permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    permission_key TEXT NOT NULL UNIQUE,
    permission_value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
