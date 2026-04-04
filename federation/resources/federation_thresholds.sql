-- F38: Federation Thresholds (Grenzwerte)

CREATE TABLE IF NOT EXISTS federation_threshold (
    threshold_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    threshold_key TEXT NOT NULL UNIQUE,
    threshold_value INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_threshold (threshold_key, threshold_value)
VALUES
    ('min_trust_required', 50),
    ('max_latency_ms', 200),
    ('max_event_payload_kb', 512)
ON CONFLICT DO NOTHING;
