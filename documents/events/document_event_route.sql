-- documents/events/document_event_route.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Leitet Events anhand ihres event_type an interne Handler weiter

CREATE OR REPLACE FUNCTION event_document_route(
    p_event_id UUID
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_event document_events%ROWTYPE;
    v_handler TEXT;
BEGIN
    SELECT *
    INTO v_event
    FROM document_events
    WHERE event_id = p_event_id;

    -- Routing-Logik
    CASE v_event.event_type
        WHEN 'CREATED' THEN
            v_handler := 'handler_document_created';
        WHEN 'UPDATED' THEN
            v_handler := 'handler_document_updated';
        WHEN 'DELETED' THEN
            v_handler := 'handler_document_deleted';
        WHEN 'VERSIONED' THEN
            v_handler := 'handler_document_versioned';
        ELSE
            v_handler := 'handler_document_generic';
    END CASE;

    -- Rückgabe des gewählten Handlers
    RETURN v_handler;
END;
$$;

COMMENT ON FUNCTION event_document_route IS
'Bestimmt anhand des Event-Typs den zuständigen internen Handler.';
