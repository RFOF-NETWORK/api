-- F30: Rollen-Definitionen für Federation Nodes

CREATE TABLE IF NOT EXISTS federation_role_map (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name TEXT NOT NULL UNIQUE,
    permissions JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_role_map (role_name, permissions)
VALUES
    ('reader', '{"events": "read", "nodes": "read"}'),
    ('writer', '{"events": "write", "nodes": "write"}'),
    ('admin', '{"events": "all", "nodes": "all", "policies": "all"}')
ON CONFLICT DO NOTHING;
