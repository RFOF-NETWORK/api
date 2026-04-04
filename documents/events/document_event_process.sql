-- documents/events/document_event_process.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Führt Routing + Handler-Ausführung + Consume in einem Schritt aus

CREATE OR REPLACE FUNCTION event_document_process(
    p_event_id UUID
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_handler TEXT;
    v_status  TEXT := 'SUCCESS';
    v_details JSONB := '{}'::jsonb;
BEGIN
    -- 1. Handler bestimmen
    v_handler := event_document_route(p_event_id);

    -- 2. Handler ausführen (dynamischer Funktionsaufruf)
    BEGIN
        PERFORM format('SELECT %I($1)', v_handler)::TEXT
        USING p_event_id;
    EXCEPTION WHEN OTHERS THEN
        v_status  := 'FAILED';
        v_details := jsonb_build_object(
            'error', SQLERRM,
            'handler', v_handler
        );
    END;

    -- 3. Consume (Status speichern)
    PERFORM event_document_consume(
        p_event_id,
        v_handler,
        v_status,
        v_details
    );

    -- 4. Rückgabe des ausgeführten Handlers
    RETURN v_handler;
END;
$$;

COMMENT ON FUNCTION event_document_process IS
'Führt Routing, Handler-Ausführung und Consume in einem atomaren Schritt aus.';
