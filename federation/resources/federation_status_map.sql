-- F28: Status Map für Federation Nodes

CREATE TABLE IF NOT EXISTS federation_status_map (
    status_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status_key TEXT NOT NULL UNIQUE,
    status_label TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_status_map (status_key, status_label)
VALUES
    ('active', 'Node is active'),
    ('inactive', 'Node is inactive'),
    ('pending', 'Node is pending approval'),
    ('blocked', 'Node is blocked due to policy violation')
ON CONFLICT DO NOTHING;
