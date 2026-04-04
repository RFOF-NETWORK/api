-- F94: Schema – Federation Views (registrierte Views)

CREATE TABLE IF NOT EXISTS federation_view (
    view_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    view_name TEXT NOT NULL UNIQUE,
    definition TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
