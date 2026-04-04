-- api/compliance/events/compliance_event_update.sql
-- Modul: COMPLIANCE
-- Zweck: Aktualisiert ein Compliance-Event (Payload, Status, Metadaten)

CREATE OR REPLACE FUNCTION compliance_event_update(
    p_event_id UUID,
    p_patch    JSONB,                 -- Patch-Objekt für Payload
    p_reason   TEXT DEFAULT 'UPDATED'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_old_payload JSONB;
    v_new_payload JSONB;
    v_update JSONB;
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

    v_old_payload := v_event.payload;

    -- 2. Patch anwenden (JSONB-Merge)
    v_new_payload := v_old_payload || p_patch;

    -- 3. Event aktualisieren
    UPDATE document_events
    SET payload = v_new_payload,
        updated_at = now()
    WHERE event_id = p_event_id;

    -- 4. Update-Objekt bauen
    v_update := jsonb_build_object(
        'event_id', p_event_id,
        'event_type', v_event.event_type,
        'entity_type', v_event.entity_type,
        'entity_id', v_event.entity_id,
        'old_payload', v_old_payload,
        'new_payload', v_new_payload,
        'reason', p_reason,
        'updated_at', now()
    );

    -- 5. Update-Log schreiben (DE-kompatibel)
    INSERT INTO document_event_update_log (
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
        v_update
    );

    -- 6. Ergebnis zurückgeben
    RETURN v_update;
END;
$$;

COMMENT ON FUNCTION compliance_event_update IS
'Aktualisiert ein Compliance-Event (Payload-Patch, Status, Metadaten) und schreibt ein Update-Log.';
