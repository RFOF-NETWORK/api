-- documents/events/document_event_bus_autorun.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Autonomer Worker, der Events abholt, routet und verarbeitet

CREATE OR REPLACE FUNCTION event_document_bus_autorun(
    p_limit INTEGER DEFAULT 50,
    p_sleep_ms INTEGER DEFAULT 200
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_batch JSONB;
    v_events JSONB;
    v_event JSONB;
    v_event_id UUID;
    v_count INTEGER;
BEGIN
    LOOP
        -- 1. Events dispatchen
        v_batch := event_document_dispatch(p_limit);

        -- 2. Events extrahieren
        v_events := v_batch;

        -- 3. Anzahl bestimmen
        v_count := jsonb_array_length(v_events);

        -- 4. Jedes Event durch den Router schicken
        FOR i IN 0 .. v_count - 1 LOOP
            v_event := v_events->i;
            v_event_id := (v_event->>'event_id')::UUID;

            PERFORM event_document_bus_router(v_event_id);
        END LOOP;

        -- 5. Wenn keine Events → schlafen
        IF v_count = 0 THEN
            PERFORM pg_sleep(p_sleep_ms / 1000.0);
        END IF;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION event_document_bus_autorun IS
'Autonomer Event-Worker: Dispatch → Router → Policy → Processing in Endlosschleife.';
