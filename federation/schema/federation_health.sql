-- F97: Schema – Federation Health Status

CREATE TABLE IF NOT EXISTS federation_health (
    health_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    component TEXT NOT NULL,
    status TEXT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
