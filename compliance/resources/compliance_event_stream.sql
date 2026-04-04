-- api/compliance/events/compliance_event_stream.sql
-- Modul: COMPLIANCE
-- Zweck: Streaming von Compliance-Events für Monitoring, Analytics und Realtime-Pipelines

CREATE OR REPLACE FUNCTION compliance_event_stream(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_stream JSONB;
BEGIN
    -- 1. Event laden
    SELECT *
    INTO v_event
    FROM document_events
    WHERE event_id = p_event_id;

    IF v_event IS NULL THEN
        RETURN jsonb_build_object(
            'error', 'EVENT_NOT_FOUND',
            'event_id', p_event_id
        );
    END IF;

    -- 2. Stream-Objekt bauen
    v_stream := jsonb_build_object(
        'event_id', p_event_id,
        'event_type', v_event.event_type,
        'entity_type', v_event.entity_type,
        'entity_id', v_event.entity_id,
        'payload', v_event.payload,
        'streamed_at', now()
    );

    -- 3. Stream-Log schreiben (DE-kompatibel)
    INSERT INTO document_event_stream_log (
        event_id,
        event_type,
        entity_type,
        entity_id,
        payload
    )
    VALUES (
        p_event_id,
        v_event.event_type,
        v_event.entity_type,
        v_event.entity_id,
        v_stream
    );

    -- 4. Ergebnis zurückgeben
    RETURN v_stream;
END;
$$;

COMMENT ON FUNCTION compliance_event_stream IS
'Erzeugt einen Stream-Eintrag für ein Compliance-Event (Realtime/Analytics).';
