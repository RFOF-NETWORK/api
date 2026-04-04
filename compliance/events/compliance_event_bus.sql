-- api/compliance/events/compliance_event_bus.sql
-- Modul: COMPLIANCE
-- Zweck: Globaler Event-Bus für Compliance-Events

CREATE OR REPLACE FUNCTION compliance_event_bus(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_dispatch JSONB;
    v_bus JSONB;
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

    -- 2. Dispatch ausführen (E9)
    v_dispatch := compliance_event_dispatch(p_event_id);

    -- 3. Bus-Objekt bauen
    v_bus := jsonb_build_object(
        'event_id', p_event_id,
        'event_type', v_event.event_type,
        'entity_type', v_event.entity_type,
        'entity_id', v_event.entity_id,
        'dispatch', v_dispatch,
        'bus_timestamp', now()
    );

    -- 4. Bus-Log schreiben (DE-kompatibel)
    INSERT INTO document_event_bus_log (
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
        v_bus
    );

    -- 5. Ergebnis zurückgeben
    RETURN v_bus;
END;
$$;

COMMENT ON FUNCTION compliance_event_bus IS
'Globaler Event-Bus für Compliance-Events, kompatibel mit der Document-Event-Engine.';
