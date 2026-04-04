-- api/compliance/events/compliance_event_metrics.sql
-- Modul: COMPLIANCE
-- Zweck: Erzeugt Metriken für Compliance-Events (KPIs, Telemetrie, Monitoring)

CREATE OR REPLACE FUNCTION compliance_event_metrics(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_compliance RECORD;
    v_metrics JSONB;
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

    -- 2. Compliance-Datensatz laden
    SELECT *
    INTO v_compliance
    FROM compliance
    WHERE compliance_id = (v_event.payload->>'compliance_id')::uuid;

    IF v_compliance IS NULL THEN
        RETURN jsonb_build_object(
            'error', 'COMPLIANCE_NOT_FOUND',
            'event_id', p_event_id
        );
    END IF;

    -- 3. Metriken berechnen
    v_metrics := jsonb_build_object(
        'event_id', p_event_id,
        'compliance_id', v_compliance.compliance_id,
        'event_type', v_event.event_type,
        'status', v_compliance.compliance_status,
        'entity_type', v_event.entity_type,
        'entity_id', v_event.entity_id,
        'created_at', v_compliance.created_at,
        'updated_at', v_compliance.updated_at,
        'latency_ms', EXTRACT(MILLISECOND FROM (now() - v_compliance.updated_at)),
        'metrics_generated_at', now()
    );

    -- 4. Metrics-Log schreiben (DE-kompatibel)
    INSERT INTO document_event_metrics_log (
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
        v_metrics
    );

    -- 5. Ergebnis zurückgeben
    RETURN v_metrics;
END;
$$;

COMMENT ON FUNCTION compliance_event_metrics IS
'Erzeugt Metriken und Telemetrie für Compliance-Events.';
