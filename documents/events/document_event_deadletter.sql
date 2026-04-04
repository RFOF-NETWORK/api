-- documents/events/document_event_deadletter.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Verschiebt ein Event endgültig in die Dead-Letter-Queue

CREATE OR REPLACE FUNCTION event_document_deadletter(
    p_event_id UUID,
    p_reason   TEXT,
    p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE document_events
    SET
        deadletter_at = now(),
        status        = 'DEADLETTER',
        details       = jsonb_build_object(
            'deadletter_reason', p_reason,
            'deadletter_at', now()
        ) || p_metadata
    WHERE event_id = p_event_id;
END;
$$;

COMMENT ON FUNCTION event_document_deadletter IS
'Markiert ein Dokument-Event als endgültig unzustellbar (Dead-Letter).';
