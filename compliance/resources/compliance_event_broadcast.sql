-- api/compliance/events/compliance_event_broadcast.sql
-- Modul: COMPLIANCE
-- Zweck: Broadcast eines Compliance-Events an alle aktiven Subscriber

CREATE OR REPLACE FUNCTION compliance_event_broadcast(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event RECORD;
    v_sub RECORD;
    v_matches JSONB := '[]'::jsonb;
    v_broadcast JSONB;
    v_callback_result JSONB;
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

    -- 2. Alle aktiven Subscriber iterieren
    FOR v_sub IN
        SELECT *
        FROM document_event_subscriptions
    LOOP
        -- Filter prüfen
        IF (
            (v_sub.filter ? 'event_type' AND v_sub.filter->>'event_type' <> v_event.event_type)
            OR
            (v_sub.filter ? 'entity_type' AND v_sub.filter->>'entity_type' <> v_event.entity_type)
            OR
            (v_sub.filter ? 'compliance_type' AND v_sub.filter->>'compliance_type' <> (v_event.payload->>'compliance_type'))
        ) THEN
            CONTINUE;
        END IF;

        -- 3. Callback ausführen (dynamischer Funktionsaufruf)
        EXECUTE format('SELECT %I($1)', v_sub.callback)
        INTO v_callback_result
        USING p_event_id;

        -- 4. Match speichern
        v_matches := v_matches || jsonb_build_object(
            'subscription_id', v_sub.subscription_id,
            'subscriber', v_sub.subscriber,
            'callback', v_sub.callback,
            'callback_result', v_callback_result
        );
    END LOOP;

    -- 5. Broadcast-Objekt bauen
    v_broadcast := jsonb_build_object(
        'event_id', p_event_id,
        'event_type', v_event.event_type,
        'entity_type', v_event.entity_type,
        'entity_id', v_event.entity_id,
        'matches', v_matches,
        'broadcasted_at', now()
    );

    -- 6. Broadcast-Log schreiben (DE-kompatibel)
    INSERT INTO document_event_broadcast_log (
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
        v_broadcast
    );

    -- 7. Ergebnis zurückgeben
    RETURN v_broadcast;
END;
$$;

COMMENT ON FUNCTION compliance_event_broadcast IS
'Broadcastet ein Compliance-Event an alle Subscriber, deren Filter matchen.';
