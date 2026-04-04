-- F22: Statische Definition der Federation Node Types

CREATE TABLE IF NOT EXISTS federation_node_type (
    type_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type_name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_node_type (type_name, description)
VALUES
    ('root', 'Primary federation root node'),
    ('regional', 'Regional federation node'),
    ('edge', 'Edge-level federation node'),
    ('external', 'External integrated node')
ON CONFLICT DO NOTHING;
