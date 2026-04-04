-- documents/events/document_event_bus_policy.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Policy-Engine für Retry-Limits, Dead-Letter-Thresholds, Routing-Regeln

CREATE OR REPLACE FUNCTION event_document_bus_policy(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event      document_events%ROWTYPE;
    v_policy     JSONB := '{}'::jsonb;
    v_retry_max  INT;
    v_retry_count INT;
BEGIN
    -- 1. Event laden
    SELECT *
    INTO v_event
    FROM document_events
    WHERE event_id = p_event_id;

    -- 2. Retry-Count bestimmen
    SELECT COUNT(*)
    INTO v_retry_count
    FROM document_events
    WHERE event_id = p_event_id
      AND status = 'RETRY';

    -- 3. Retry-Limit bestimmen (Default 3)
    SELECT COALESCE(
        (SELECT (metadata->>'retry_limit')::INT
         FROM document_event_policies
         WHERE event_type = v_event.event_type),
        3
    )
    INTO v_retry_max;

    -- 4. Dead-Letter-Entscheidung
    IF v_retry_count >= v_retry_max THEN
        v_policy := v_policy || jsonb_build_object(
            'action', 'DEADLETTER',
            'reason', 'RETRY_LIMIT_EXCEEDED',
            'retry_count', v_retry_count,
            'retry_limit', v_retry_max
        );
        RETURN v_policy;
    END IF;

    -- 5. Routing-Override prüfen
    IF EXISTS (
        SELECT 1
        FROM document_event_policies
        WHERE event_type = v_event.event_type
          AND metadata ? 'route_to'
    ) THEN
        v_policy := v_policy || jsonb_build_object(
            'action', 'ROUTE_OVERRIDE',
            'route_to',
                (SELECT metadata->>'route_to'
                 FROM document_event_policies
                 WHERE event_type = v_event.event_type)
        );
        RETURN v_policy;
    END IF;

    -- 6. Default: normaler Prozess
    v_policy := v_policy || jsonb_build_object(
        'action', 'PROCESS'
    );

    RETURN v_policy;
END;
$$;

COMMENT ON FUNCTION event_document_bus_policy IS
'Policy-Engine für Retry-Limits, Dead-Letter-Thresholds und Routing-Overrides.';
