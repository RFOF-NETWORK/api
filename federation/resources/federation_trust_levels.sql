-- F21: Trust-Level-Definitionen

CREATE TABLE IF NOT EXISTS federation_trust_level (
    level_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    level_name TEXT NOT NULL UNIQUE,
    min_value INT NOT NULL,
    max_value INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_trust_level (level_name, min_value, max_value)
VALUES
    ('critical', 0, 49),
    ('degraded', 50, 79),
    ('healthy', 80, 100)
ON CONFLICT DO NOTHING;
