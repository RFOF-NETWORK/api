-- documents/events/document_event_stream.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Kontinuierlicher Event-Stream (Polling-Loop)

CREATE OR REPLACE FUNCTION event_document_stream(
    p_limit INTEGER DEFAULT 50,
    p_sleep_ms INTEGER DEFAULT 200
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_batch JSONB;
    v_count INTEGER;
BEGIN
    LOOP
        -- 1. Batch verarbeiten
        v_batch := event_document_process_batch(p_limit);

        -- 2. Anzahl verarbeiteter Events extrahieren
        v_count := (v_batch->>'count')::INTEGER;

        -- 3. Wenn nichts zu tun ist → kurz schlafen
        IF v_count = 0 THEN
            PERFORM pg_sleep(p_sleep_ms / 1000.0);
        END IF;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION event_document_stream IS
'Startet einen kontinuierlichen Event-Stream mit Polling-Loop.';
