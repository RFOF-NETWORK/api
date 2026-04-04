-- F49: Retry Mechanismus für Deadletter Events

CREATE OR REPLACE FUNCTION federation_event_retry(
    p_limit INT DEFAULT 50
)
RETURNS SETOF federation_event_deadletter
LANGUAGE sql
AS $$
    SELECT *
    FROM federation_event_deadletter
    ORDER BY created_at ASC
    LIMIT p_limit;
$$;
