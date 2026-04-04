-- api/compliance/events/compliance_event_retry.sql
-- Modul: COMPLIANCE
-- Zweck: Retry-Mechanismus für fehlgeschlagene Compliance-Events

CREATE OR REPLACE FUNCTION compliance_event_retry(
    p_event_id UUID,
    p_reason   TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_retry_count INTEGER := 0;
    v_retry JSONB;
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

    -- 2. Retry-Count aus Payload lesen
    IF (v_event.payload ? 'retry_count') THEN
        v_retry_count := (v_event.payload->>'retry_count')::INTEGER;
    END IF;

    v_retry_count := v_retry_count + 1;

    -- 3. Retry-Objekt bauen
    v_retry := jsonb_build_object(
        'event_id', p_event_id,
        'event_type', v_event.event_type,
        'retry_count', v_retry_count,
        'reason', p_reason,
        'retry_timestamp', now()
    );

    -- 4. Retry-Log schreiben (DE-kompatibel)
    INSERT INTO document_event_retry_log (
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
        v_retry
    );

    -- 5. Event-Payload aktualisieren (Backoff-Strategie)
    UPDATE document_events
    SET payload = v_event.payload || jsonb_build_object(
        'retry_count', v_retry_count,
        'last_retry_at', now()
    )
    WHERE event_id = p_event_id;

    -- 6. Ergebnis zurückgeben
    RETURN v_retry;
END;
$$;

COMMENT ON FUNCTION compliance_event_retry IS
'Retry-Mechanismus für fehlgeschlagene Compliance-Events (Backoff, Counter, Logging).';
