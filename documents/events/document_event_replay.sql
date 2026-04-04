-- documents/events/document_event_replay.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Reaktiviert ein Dead-Letter-Event und setzt es zurück in den Pending-Zustand

CREATE OR REPLACE FUNCTION event_document_replay(
    p_event_id UUID,
    p_reason   TEXT DEFAULT 'REPLAY'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE document_events
    SET
        dispatched_at = NULL,
        processed_at  = NULL,
        deadletter_at = NULL,
        status        = 'REPLAY',
        details       = jsonb_build_object(
            'replay_reason', p_reason,
            'replay_at', now()
        )
    WHERE event_id = p_event_id;
END;
$$;

COMMENT ON FUNCTION event_document_replay IS
'Reaktiviert ein Dead-Letter-Event und setzt es zurück in den Pending-Zustand.';
