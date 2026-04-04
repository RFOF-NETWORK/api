-- api/compliance/events/compliance_event_emit.sql
-- Modul: COMPLIANCE
-- Zweck: Emit eines Compliance-Events in das globale Event-System

CREATE OR REPLACE FUNCTION compliance_event_emit(
    p_event_type      TEXT,        -- CHECKED, UPDATED, RESOLVED, FAILED, EVALUATED
    p_compliance_id   UUID,
    p_entity_type     TEXT,
    p_entity_id       UUID,
    p_payload         JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event_id UUID;
    v_event JSONB;
BEGIN
    -- 1. Event-Objekt bauen
    v_event := jsonb_build_object(
        'event_type', p_event_type,
        'compliance_id', p_compliance_id,
        'entity_type', p_entity_type,
        'entity_id', p_entity_id,
        'payload', p_payload,
        'emitted_at', now()
    );

    -- 2. Event in globale Event-Tabelle schreiben
    INSERT INTO document_events (
        event_type,
        entity_type,
        entity_id,
        payload
    )
    VALUES (
        p_event_type,
        p_entity_type,
        p_entity_id,
        v_event
    )
    RETURNING event_id INTO v_event_id;

    -- 3. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'event_id', v_event_id,
        'event', v_event
    );
END;
$$;

COMMENT ON FUNCTION compliance_event_emit IS
'Emit eines Compliance-Events in das globale Document-Event-System.';
