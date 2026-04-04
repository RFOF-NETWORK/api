-- documents/events/document_event_emit.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Erzeugt ein generisches Dokument-Event

CREATE OR REPLACE FUNCTION event_document_emit(
    p_document_id UUID,
    p_event_type  TEXT,      -- z.B. 'CREATED', 'UPDATED', 'DELETED', 'VERSIONED'
    p_actor_id    UUID,
    p_payload     JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_event_id UUID := gen_random_uuid();
BEGIN
    INSERT INTO document_events (
        event_id,
        document_id,
        event_type,
        actor_id,
        payload
    )
    VALUES (
        v_event_id,
        p_document_id,
        p_event_type,
        p_actor_id,
        p_payload
    );

    RETURN v_event_id;
END;
$$;

COMMENT ON FUNCTION event_document_emit IS
'Erzeugt ein generisches Dokument-Event für Event-basierte Verarbeitung.';
