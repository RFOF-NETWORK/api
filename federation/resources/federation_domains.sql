-- F19: Statische Domain-Liste für Federation

CREATE TABLE IF NOT EXISTS federation_domain (
    domain_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_domain (domain_name, description)
VALUES
    ('core', 'Primary federation domain'),
    ('edge', 'Edge federation nodes'),
    ('external', 'External trusted federation partners')
ON CONFLICT DO NOTHING;
