-- F59: Event Router (entscheidet, wohin Events gehen)

CREATE OR REPLACE FUNCTION federation_event_router(
    p_event_type TEXT
)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT target
    FROM federation_event_bus
    WHERE route_key = p_event_type;
$$;
