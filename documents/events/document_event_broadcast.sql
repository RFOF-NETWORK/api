-- documents/events/document_event_broadcast.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Benachrichtigt alle registrierten Subscriber eines Event-Typs

CREATE OR REPLACE FUNCTION event_document_broadcast(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_event       document_events%ROWTYPE;
    v_subscribers RECORD;
    v_results     JSONB := '[]'::jsonb;
BEGIN
    -- 1. Event laden
    SELECT *
    INTO v_event
    FROM document_events
    WHERE event_id = p_event_id;

    -- 2. Alle Subscriber für diesen Event-Typ holen
    FOR v_subscribers IN
        SELECT handler, metadata
        FROM document_event_subscriptions
        WHERE event_type = v_event.event_type
    LOOP
        BEGIN
            -- 3. Handler ausführen
            PERFORM format('SELECT %I($1)', v_subscribers.handler)::TEXT
            USING p_event_id;

            -- 4. Erfolg protokollieren
            v_results := v_results || jsonb_build_object(
                'handler', v_subscribers.handler,
                'status', 'SUCCESS'
            );

        EXCEPTION WHEN OTHERS THEN
            -- 5. Fehler protokollieren
            v_results := v_results || jsonb_build_object(
                'handler', v_subscribers.handler,
                'status', 'FAILED',
                'error', SQLERRM
            );
        END;
    END LOOP;

    -- 6. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'event_id', p_event_id,
        'event_type', v_event.event_type,
        'results', v_results
    );
END;
$$;

COMMENT ON FUNCTION event_document_broadcast IS
'Benachrichtigt alle registrierten Subscriber eines Event-Typs und liefert Handler-Resultate zurück.';
