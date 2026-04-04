-- F73: Schema – Federation Policy

CREATE TABLE IF NOT EXISTS federation_policy (
    policy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_name TEXT NOT NULL UNIQUE,
    policy_data JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
