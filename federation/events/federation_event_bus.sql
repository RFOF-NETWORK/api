-- F54: Event Bus (logical event routing)

CREATE TABLE IF NOT EXISTS federation_event_bus (
    bus_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_key TEXT NOT NULL UNIQUE,
    target TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION federation_event_bus_route(
    p_route_key TEXT
)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT target
    FROM federation_event_bus
    WHERE route_key = p_route_key;
$$;
