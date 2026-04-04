-- F46: Replay Federation Events (replay by timestamp or ID)

CREATE OR REPLACE FUNCTION federation_event_replay(
    p_from TIMESTAMPTZ,
    p_to   TIMESTAMPTZ
)
RETURNS SETOF federation_event
LANGUAGE sql
AS $$
    SELECT *
    FROM federation_event
    WHERE created_at BETWEEN p_from AND p_to
    ORDER BY created_at ASC;
$$;
