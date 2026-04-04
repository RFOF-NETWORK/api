-- F41: Region Map für Federation Nodes

CREATE TABLE IF NOT EXISTS federation_region_map (
    region_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    region_key TEXT NOT NULL UNIQUE,
    region_label TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_region_map (region_key, region_label)
VALUES
    ('eu-central', 'Europe Central'),
    ('eu-west', 'Europe West'),
    ('us-east', 'US East'),
    ('us-west', 'US West'),
    ('ap-south', 'Asia Pacific South')
ON CONFLICT DO NOTHING;
