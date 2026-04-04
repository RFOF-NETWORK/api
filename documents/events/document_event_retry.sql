-- documents/events/document_event_retry.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Setzt fehlgeschlagene Events zurück in den Pending-Zustand

CREATE OR REPLACE FUNCTION event_document_retry(
    p_event_id UUID,
    p_reason   TEXT DEFAULT 'RETRY'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE document_events
    SET
        dispatched_at = NULL,
        processed_at  = NULL,
        status        = 'RETRY',
        details       = jsonb_build_object(
            'retry_reason', p_reason,
            'retry_at', now()
        )
    WHERE event_id = p_event_id;
END;
$$;

COMMENT ON FUNCTION event_document_retry IS
'Setzt ein fehlgeschlagenes Dokument-Event zurück in den Pending-Zustand, um es erneut zu verarbeiten.';
