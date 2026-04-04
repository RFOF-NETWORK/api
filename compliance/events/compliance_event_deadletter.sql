-- api/compliance/events/compliance_event_deadletter.sql
-- Modul: COMPLIANCE
-- Zweck: Dead-Letter-Queue für endgültig gescheiterte Compliance-Events

CREATE OR REPLACE FUNCTION compliance_event_deadletter(
    p_event_id UUID,
    p_reason   TEXT DEFAULT 'UNSPECIFIED'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_dead JSONB;
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

    -- 2. Dead-Letter-Objekt bauen
    v_dead := jsonb_build_object(
        'event_id', p_event_id,
        'event_type', v_event.event_type,
        'entity_type', v_event.entity_type,
        'entity_id', v_event.entity_id,
        'payload', v_event.payload,
        'reason', p_reason,
        'deadletter_timestamp', now()
    );

    -- 3. Dead-Letter-Log schreiben (DE-kompatibel)
    INSERT INTO document_event_deadletter_log (
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
        v_dead
    );

    -- 4. Ergebnis zurückgeben
    RETURN v_dead;
END;
$$;

COMMENT ON FUNCTION compliance_event_deadletter IS
'Verschiebt ein endgültig gescheitertes Compliance-Event in die Dead-Letter-Queue.';
