-- documents/events/document_event_consume.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Konsumiert ein einzelnes Dokument-Event und markiert es als verarbeitet

CREATE OR REPLACE FUNCTION event_document_consume(
    p_event_id UUID,
    p_handler  TEXT,          -- Name des Consumers/Handlers
    p_status   TEXT,          -- z.B. 'SUCCESS', 'FAILED'
    p_details  JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE document_events
    SET
        processed_at = now(),
        handler      = p_handler,
        status       = p_status,
        details      = p_details
    WHERE event_id = p_event_id;

    -- Keine Audit-Logs hier: Events sind selbst die Audit-Schicht
END;
$$;

COMMENT ON FUNCTION event_document_consume IS
'Markiert ein Dokument-Event als verarbeitet und speichert Handler-Status.';
