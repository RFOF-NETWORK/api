-- documents/events/document_event_dispatch.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Holt un-dispatched Events, markiert sie und gibt sie zur Weiterverarbeitung zurück

CREATE OR REPLACE FUNCTION event_document_dispatch(
    p_limit INTEGER DEFAULT 100
)
RETURNS SETOF document_events
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH next_events AS (
        SELECT *
        FROM document_events
        WHERE dispatched_at IS NULL
        ORDER BY created_at
        LIMIT p_limit
        FOR UPDATE SKIP LOCKED
    )
    UPDATE document_events e
    SET dispatched_at = now()
    FROM next_events ne
    WHERE e.event_id = ne.event_id
    RETURNING ne.*;
END;
$$;

COMMENT ON FUNCTION event_document_dispatch IS
'Markiert un-dispatched Dokument-Events als dispatched und gibt sie zur Weiterverarbeitung zurück.';
