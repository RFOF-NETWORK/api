-- F36: Permission Map für Federation (feingranulare Rechte)

CREATE TABLE IF NOT EXISTS federation_permission_map (
    permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    permission_key TEXT NOT NULL UNIQUE,
    permission_value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_permission_map (permission_key, permission_value)
VALUES
    ('read_nodes', '{"allowed": true}'),
    ('write_nodes', '{"allowed": true}'),
    ('read_events', '{"allowed": true}'),
    ('write_events', '{"allowed": false}'),
    ('admin_all', '{"allowed": true}')
ON CONFLICT DO NOTHING;
