-- api/compliance/events/compliance_event_history.sql
-- Modul: COMPLIANCE
-- Zweck: Liefert eine vollständige chronologische Audit-Historie eines Compliance-Events

CREATE OR REPLACE FUNCTION compliance_event_history(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_history JSONB := '[]'::jsonb;
BEGIN
    -- 1. Event laden (Startpunkt der Historie)
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

    -- 2. Alle relevanten Logs in chronologischer Reihenfolge sammeln
    WITH logs AS (
        SELECT created_at, 'EVENT' AS type, payload
        FROM document_events
        WHERE event_id = p_event_id

        UNION ALL
        SELECT created_at, 'UPDATE', payload
        FROM document_event_update_log
        WHERE event_id = p_event_id

        UNION ALL
        SELECT created_at, 'ROUTE', payload
        FROM document_event_route_log
        WHERE event_id = p_event_id

        UNION ALL
        SELECT created_at, 'DISPATCH', payload
        FROM document_event_dispatch_log
        WHERE event_id = p_event_id

        UNION ALL
        SELECT created_at, 'BUS', payload
        FROM document_event_bus_log
        WHERE event_id = p_event_id

        UNION ALL
        SELECT created_at, 'STREAM', payload
        FROM document_event_stream_log
        WHERE event_id = p_event_id

        UNION ALL
        SELECT created_at, 'METRICS', payload
        FROM document_event_metrics_log
        WHERE event_id = p_event_id

        UNION ALL
        SELECT created_at, 'RETRY', payload
        FROM document_event_retry_log
        WHERE event_id = p_event_id

        UNION ALL
        SELECT created_at, 'DEADLETTER', payload
        FROM document_event_deadletter_log
        WHERE event_id = p_event_id

        UNION ALL
        SELECT created_at, 'REPLAY', payload
        FROM document_event_replay_log
        WHERE event_id = p_event_id

        UNION ALL
        SELECT created_at, 'BROADCAST', payload
        FROM document_event_broadcast_log
        WHERE event_id = p_event_id
    )
    SELECT jsonb_agg(
        jsonb_build_object(
            'timestamp', created_at,
            'type', type,
            'payload', payload
        )
        ORDER BY created_at
    )
    INTO v_history
    FROM logs;

    -- 3. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'event_id', p_event_id,
        'history', COALESCE(v_history, '[]'::jsonb),
        'history_generated_at', now()
    );
END;
$$;

COMMENT ON FUNCTION compliance_event_history IS
'Liefert eine vollständige chronologische Audit-Historie eines Compliance-Events.';
