-- F40: Federation Constraints (statische Systemregeln)

CREATE TABLE IF NOT EXISTS federation_constraint (
    constraint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    constraint_key TEXT NOT NULL UNIQUE,
    constraint_value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_constraint (constraint_key, constraint_value)
VALUES
    ('allow_cross_domain', '{"enabled": false}'),
    ('require_node_signature', '{"enabled": true}'),
    ('max_child_nodes', '{"value": 50}')
ON CONFLICT DO NOTHING;
