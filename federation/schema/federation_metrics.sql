-- F75: Schema – Federation Metrics

CREATE TABLE IF NOT EXISTS federation_metrics (
    metric_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_key TEXT NOT NULL UNIQUE,
    metric_value NUMERIC NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
