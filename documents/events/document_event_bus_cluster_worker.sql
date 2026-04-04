-- documents/events/document_event_bus_cluster_worker.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Cluster-fähiger Worker (Heartbeat, Sharding, Locking, Routing)

CREATE OR REPLACE FUNCTION event_document_bus_cluster_worker(
    p_node_id TEXT,
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
    v_shard_node TEXT;
    v_locked BOOLEAN;
    v_count INTEGER;
BEGIN
    LOOP
        -- 1. Heartbeat senden
        PERFORM event_document_bus_cluster_heartbeat(p_node_id);

        -- 2. Events dispatchen
        v_batch := event_document_dispatch(p_limit);
        v_events := v_batch;
        v_count := jsonb_array_length(v_events);

        -- 3. Events iterieren
        FOR i IN 0 .. v_count - 1 LOOP
            v_event := v_events->i;
            v_event_id := (v_event->>'event_id')::UUID;

            -- 4. Shard bestimmen
            v_shard_node := event_document_bus_cluster_shard(v_event_id);

            -- 5. Nur verarbeiten, wenn dieses Node zuständig ist
            IF v_shard_node IS NULL OR v_shard_node <> p_node_id THEN
                CONTINUE;
            END IF;

            -- 6. Cluster-Lock setzen
            v_locked := event_document_bus_cluster_lock(v_event_id, p_node_id);

            IF NOT v_locked THEN
                CONTINUE;
            END IF;

            -- 7. Router ausführen
            PERFORM event_document_bus_router(v_event_id);
        END LOOP;

        -- 8. Wenn keine Events → schlafen
        IF v_count = 0 THEN
            PERFORM pg_sleep(p_sleep_ms / 1000.0);
        END IF;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION event_document_bus_cluster_worker IS
'Cluster-fähiger Worker: Heartbeat → Sharding → Locking → Routing in Endlosschleife.';
