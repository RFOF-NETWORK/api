-- F64: Event History (Historische Event-Abfragen)

CREATE OR REPLACE FUNCTION federation_event_history(
    p_event_type TEXT
)
RETURNS SETOF federation_event
LANGUAGE sql
AS $$
    SELECT *
    FROM federation_event
    WHERE event_type = p_event_type
    ORDER BY created_at ASC;
$$;
