-- api/compliance/events/compliance_event_status.sql
-- Modul: COMPLIANCE
-- Zweck: Liefert einen vollständigen Status-Snapshot eines Compliance-Events

CREATE OR REPLACE FUNCTION compliance_event_status(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_compliance RECORD;
    v_retry RECORD;
    v_dead RECORD;
    v_status JSONB;
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

    -- 3. Retry-Status laden (letzter Eintrag)
    SELECT *
    INTO v_retry
    FROM document_event_retry_log
    WHERE event_id = p_event_id
    ORDER BY created_at DESC
    LIMIT 1;

    -- 4. Deadletter-Status laden (falls vorhanden)
    SELECT *
    INTO v_dead
    FROM document_event_deadletter_log
    WHERE event_id = p_event_id
    LIMIT 1;

    -- 5. Status-Objekt bauen
    v_status := jsonb_build_object(
        'event', jsonb_build_object(
            'event_id', v_event.event_id,
            'event_type', v_event.event_type,
            'entity_type', v_event.entity_type,
            'entity_id', v_event.entity_id,
            'payload', v_event.payload,
            'created_at', v_event.created_at,
            'updated_at', v_event.updated_at
        ),
        'compliance', CASE WHEN v_compliance IS NULL THEN NULL ELSE jsonb_build_object(
            'compliance_id', v_compliance.compliance_id,
            'status', v_compliance.compliance_status,
            'created_at', v_compliance.created_at,
            'updated_at', v_compliance.updated_at
        ) END,
        'retry', CASE WHEN v_retry IS NULL THEN NULL ELSE jsonb_build_object(
            'retry_count', (v_retry.payload->>'retry_count')::int,
            'last_retry_at', v_retry.payload->>'retry_timestamp'
        ) END,
        'deadletter', CASE WHEN v_dead IS NULL THEN NULL ELSE jsonb_build_object(
            'reason', v_dead.payload->>'reason',
            'deadletter_timestamp', v_dead.payload->>'deadletter_timestamp'
        ) END,
        'status_generated_at', now()
    );

    -- 6. Ergebnis zurückgeben
    RETURN v_status;
END;
$$;

COMMENT ON FUNCTION compliance_event_status IS
'Liefert einen vollständigen Status-Snapshot eines Compliance-Events (Event, Compliance, Retry, Deadletter).';
