-- F68: Schema – Federation Node

CREATE TABLE IF NOT EXISTS federation_node (
    federation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    node_name TEXT NOT NULL,
    domain TEXT NOT NULL,
    node_type TEXT NOT NULL,
    trust_level INT NOT NULL DEFAULT 80,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
