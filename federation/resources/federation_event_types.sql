-- F31: Statische Definition aller Federation Event Types

CREATE TABLE IF NOT EXISTS federation_event_type (
    type_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type_name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_event_type (type_name, description)
VALUES
    ('node_registered', 'A federation node has been registered'),
    ('node_updated', 'A federation node has been updated'),
    ('node_deleted', 'A federation node has been removed'),
    ('subscription_created', 'A subscription has been created'),
    ('subscription_removed', 'A subscription has been removed'),
    ('trust_changed', 'Trust level of a node has changed')
ON CONFLICT DO NOTHING;
