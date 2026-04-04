-- F82: Schema – Federation Capacity

CREATE TABLE IF NOT EXISTS federation_capacity (
    capacity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    capacity_key TEXT NOT NULL UNIQUE,
    capacity_value INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
