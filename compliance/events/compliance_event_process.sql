-- api/compliance/events/compliance_event_process.sql
-- Modul: COMPLIANCE
-- Zweck: Verarbeitung eines Compliance-Events

CREATE OR REPLACE FUNCTION compliance_event_process(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_compliance RECORD;
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

    -- 3. Prozesslogik (Platzhalter, später E8–E10)
    v_result := jsonb_build_object(
        'event_id', p_event_id,
        'event_type', v_event.event_type,
        'compliance_id', v_compliance.compliance_id,
        'status_before', v_compliance.compliance_status,
        'status_after', v_compliance.compliance_status,
        'processed_at', now()
    );

    -- 4. Ergebnis zurückgeben
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION compliance_event_process IS
'Verarbeitet ein Compliance-Event und liefert ein deterministisches Prozessobjekt zurück.';
