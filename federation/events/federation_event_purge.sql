-- F47: Purge old Federation Events

CREATE OR REPLACE FUNCTION federation_event_purge(
    p_before TIMESTAMPTZ
)
RETURNS INT
LANGUAGE sql
AS $$
    DELETE FROM federation_event
    WHERE created_at < p_before
    RETURNING 1;
$$;
