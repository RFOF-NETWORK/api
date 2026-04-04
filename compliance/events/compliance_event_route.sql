-- api/compliance/events/compliance_event_route.sql
-- Modul: COMPLIANCE
-- Zweck: Routing eines Compliance-Events zu der passenden Action

CREATE OR REPLACE FUNCTION compliance_event_route(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_compliance_id UUID;
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

    v_compliance_id := (v_event.payload->>'compliance_id')::uuid;

    -- 2. Routing nach Event-Typ
    CASE v_event.event_type

        WHEN 'CHECKED' THEN
            v_result := compliance_update(
                v_compliance_id,
                NULL,
                jsonb_build_object('routed_from', 'CHECKED')
            );

        WHEN 'UPDATED' THEN
            v_result := compliance_evaluate(
                v_event.payload->>'compliance_type',
                v_event.entity_type,
                v_event.entity_id,
                (v_event.payload->'rules'),
                (v_event.payload->'payload')
            );

        WHEN 'RESOLVED' THEN
            v_result := compliance_resolve(
                v_compliance_id,
                'RESOLVED',
                'Auto-routed from RESOLVED event'
            );

        WHEN 'FAILED' THEN
            v_result := compliance_resolve(
                v_compliance_id,
                'FAILED',
                'Auto-routed from FAILED event'
            );

        WHEN 'EVALUATED' THEN
            v_result := jsonb_build_object(
                'status', 'NO_ACTION',
                'info', 'Evaluation event acknowledged'
            );

        ELSE
            v_result := jsonb_build_object(
                'status', 'NO_ROUTE',
                'event_type', v_event.event_type
            );
    END CASE;

    -- 3. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'event_id', p_event_id,
        'event_type', v_event.event_type,
        'route_result', v_result,
        'routed_at', now()
    );
END;
$$;

COMMENT ON FUNCTION compliance_event_route IS
'Routet ein Compliance-Event zu der passenden Action.';
