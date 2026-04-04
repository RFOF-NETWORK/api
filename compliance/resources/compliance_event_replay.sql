-- api/compliance/events/compliance_event_replay.sql
-- Modul: COMPLIANCE
-- Zweck: Replay eines Compliance-Events für Reprocessing, Audits und Re-Evaluation

CREATE OR REPLACE FUNCTION compliance_event_replay(
    p_event_id UUID,
    p_mode     TEXT DEFAULT 'FULL'   -- FULL, ROUTE_ONLY, DISPATCH_ONLY, BUS_ONLY
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_replay JSONB;
    v_result JSONB;
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

    -- 2. Replay-Modus bestimmen
    CASE p_mode

        WHEN 'FULL' THEN
            v_result := jsonb_build_object(
                'process',  compliance_event_process(p_event_id),
                'route',    compliance_event_route(p_event_id),
                'dispatch', compliance_event_dispatch(p_event_id),
                'bus',      compliance_event_bus(p_event_id),
                'stream',   compliance_event_stream(p_event_id),
                'metrics',  compliance_event_metrics(p_event_id)
            );

        WHEN 'ROUTE_ONLY' THEN
            v_result := compliance_event_route(p_event_id);

        WHEN 'DISPATCH_ONLY' THEN
            v_result := compliance_event_dispatch(p_event_id);

        WHEN 'BUS_ONLY' THEN
            v_result := compliance_event_bus(p_event_id);

        ELSE
            RETURN jsonb_build_object(
                'error', 'INVALID_REPLAY_MODE',
                'mode', p_mode
            );
    END CASE;

    -- 3. Replay-Objekt bauen
    v_replay := jsonb_build_object(
        'event_id', p_event_id,
        'event_type', v_event.event_type,
        'mode', p_mode,
        'result', v_result,
        'replayed_at', now()
    );

    -- 4. Replay-Log schreiben (DE-kompatibel)
    INSERT INTO document_event_replay_log (
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
        v_replay
    );

    -- 5. Ergebnis zurückgeben
    RETURN v_replay;
END;
$$;

COMMENT ON FUNCTION compliance_event_replay IS
'Replayed ein Compliance-Event für Reprocessing, Routing, Dispatch oder Bus.';
