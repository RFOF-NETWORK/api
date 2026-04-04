-- api/compliance/events/compliance_event_dispatch.sql
-- Modul: COMPLIANCE
-- Zweck: Dispatch eines Compliance-Events in das Routing/Worker-System

CREATE OR REPLACE FUNCTION compliance_event_dispatch(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_route_result JSONB;
    v_dispatch JSONB;
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

    -- 2. Routing ausführen (E8)
    v_route_result := compliance_event_route(p_event_id);

    -- 3. Dispatch-Objekt bauen
    v_dispatch := jsonb_build_object(
        'event_id', p_event_id,
        'event_type', v_event.event_type,
        'entity_type', v_event.entity_type,
        'entity_id', v_event.entity_id,
        'route_result', v_route_result,
        'dispatched_at', now()
    );

    -- 4. Dispatch in globale Event-Dispatch-Tabelle schreiben (DE-kompatibel)
    INSERT INTO document_event_dispatch_log (
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
        v_dispatch
    );

    -- 5. Ergebnis zurückgeben
    RETURN v_dispatch;
END;
$$;

COMMENT ON FUNCTION compliance_event_dispatch IS
'Dispatch eines Compliance-Events in das Routing- und Worker-System.';
