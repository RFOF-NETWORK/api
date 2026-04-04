-- documents/events/document_event_process_batch.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Batch-Verarbeitung mehrerer Dokument-Events

CREATE OR REPLACE FUNCTION event_document_process_batch(
    p_limit INTEGER DEFAULT 100
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_events   document_events[];
    v_event    document_events;
    v_handler  TEXT;
    v_results  JSONB := '[]'::jsonb;
BEGIN
    -- 1. Events dispatchen
    SELECT ARRAY(
        SELECT *
        FROM event_document_dispatch(p_limit)
    )
    INTO v_events;

    -- 2. Jedes Event einzeln verarbeiten
    FOREACH v_event IN ARRAY v_events LOOP
        v_handler := event_document_process(v_event.event_id);

        v_results := v_results || jsonb_build_object(
            'event_id', v_event.event_id,
            'event_type', v_event.event_type,
            'handler', v_handler
        );
    END LOOP;

    -- 3. Batch-Result zurückgeben
    RETURN jsonb_build_object(
        'count', COALESCE(array_length(v_events, 1), 0),
        'results', v_results
    );
END;
$$;

COMMENT ON FUNCTION event_document_process_batch IS
'Verarbeitet mehrere Dokument-Events in einem deterministischen Batch.';
