-- F42: Capacity Map für Federation Nodes

CREATE TABLE IF NOT EXISTS federation_capacity_map (
    capacity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    capacity_key TEXT NOT NULL UNIQUE,
    capacity_value INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_capacity_map (capacity_key, capacity_value)
VALUES
    ('max_events_buffer', 100000),
    ('max_nodes_per_region', 500),
    ('max_active_subscriptions', 20000)
ON CONFLICT DO NOTHING;
