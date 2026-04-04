-- F78: Schema – Federation Constraints (Systemregeln)

CREATE TABLE IF NOT EXISTS federation_constraint (
    constraint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    constraint_key TEXT NOT NULL UNIQUE,
    constraint_value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
