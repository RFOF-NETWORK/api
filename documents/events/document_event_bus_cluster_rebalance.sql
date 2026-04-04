-- documents/events/document_event_bus_cluster_rebalance.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Rebalancing der Shards nach Node-Ausfall oder Node-Zugang

CREATE OR REPLACE FUNCTION event_document_bus_cluster_rebalance()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_nodes TEXT[];
    v_events JSONB;
    v_event JSONB;
    v_event_id UUID;
    v_target_node TEXT;
    v_old_node TEXT;
    v_reassigned INT := 0;
BEGIN
    -- 1. Aktive Nodes bestimmen
    SELECT ARRAY(
        SELECT node_id
        FROM document_event_cluster_nodes
        WHERE last_seen > now() - INTERVAL '10 seconds'
        ORDER BY node_id
    )
    INTO v_nodes;

    IF array_length(v_nodes, 1) IS NULL THEN
        RETURN jsonb_build_object(
            'status', 'NO_ACTIVE_NODES'
        );
    END IF;

    -- 2. Alle Events laden, die noch nicht verarbeitet wurden
    SELECT jsonb_agg(
        jsonb_build_object(
            'event_id', event_id,
            'event_type', event_type
        )
    )
    INTO v_events
    FROM document_events
    WHERE status IN ('PENDING', 'RETRY');

    IF v_events IS NULL THEN
        RETURN jsonb_build_object(
            'status', 'NO_EVENTS'
        );
    END IF;

    -- 3. Events iterieren und Shard neu bestimmen
    FOR i IN 0 .. jsonb_array_length(v_events) - 1 LOOP
        v_event := v_events->i;
        v_event_id := (v_event->>'event_id')::UUID;

        -- 3a. Bisheriger Lock-Owner
        SELECT node_id
        INTO v_old_node
        FROM document_event_cluster_locks
        WHERE event_id = v_event_id;

        -- 3b. Neuer Shard-Node
        v_target_node := event_document_bus_cluster_shard(v_event_id);

        -- 3c. Wenn Node gleich → nichts tun
        IF v_target_node = v_old_node THEN
            CONTINUE;
        END IF;

        -- 3d. Lock freigeben
        DELETE FROM document_event_cluster_locks
        WHERE event_id = v_event_id;

        v_reassigned := v_reassigned + 1;
    END LOOP;

    -- 4. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'status', 'REBALANCED',
        'active_nodes', v_nodes,
        'events_reassigned', v_reassigned,
        'timestamp', now()
    );
END;
$$;

COMMENT ON FUNCTION event_document_bus_cluster_rebalance IS
'Rebalanced Shards nach Node-Ausfall oder Node-Zugang; setzt Locks zurück und verteilt Events neu.';
