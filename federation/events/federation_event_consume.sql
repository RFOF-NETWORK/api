-- F44: Consume Federation Events (generic consumer)

CREATE OR REPLACE FUNCTION federation_event_consume(
    p_limit INT DEFAULT 100
)
RETURNS SETOF federation_event
LANGUAGE sql
AS $$
    SELECT *
    FROM federation_event
    ORDER BY created_at ASC
    LIMIT p_limit;
$$;
