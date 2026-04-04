-- documents/events/document_event_bus_cluster_supervisor.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Überwacht Cluster-Nodes, entfernt inaktive Nodes, gibt Locks frei, führt Leader-Failover durch

CREATE OR REPLACE FUNCTION event_document_bus_cluster_supervisor(
    p_timeout_seconds INT DEFAULT 10
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_now TIMESTAMP := now();
    v_timeout INTERVAL := (p_timeout_seconds || ' seconds')::INTERVAL;
    v_dead_nodes TEXT[];
    v_old_leader TEXT;
    v_new_leader TEXT;
BEGIN
    -- 1. Inaktive Nodes bestimmen
    SELECT ARRAY(
        SELECT node_id
        FROM document_event_cluster_nodes
        WHERE last_seen < v_now - v_timeout
    )
    INTO v_dead_nodes;

    -- 2. Locks freigeben, die zu toten Nodes gehören
    DELETE FROM document_event_cluster_locks
    WHERE node_id = ANY(v_dead_nodes);

    -- 3. Tote Nodes entfernen
    DELETE FROM document_event_cluster_nodes
    WHERE node_id = ANY(v_dead_nodes);

    -- 4. Leader vor Failover bestimmen
    SELECT node_id
    INTO v_old_leader
    FROM document_event_cluster_nodes
    ORDER BY created_at ASC
    LIMIT 1;

    -- 5. Leader nach Failover bestimmen
    SELECT node_id
    INTO v_new_leader
    FROM document_event_cluster_nodes
    ORDER BY created_at ASC
    LIMIT 1;

    -- 6. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'timestamp', v_now,
        'dead_nodes', v_dead_nodes,
        'old_leader', v_old_leader,
        'new_leader', v_new_leader,
        'locks_released', jsonb_build_object(
            'count', (
                SELECT COUNT(*)
                FROM document_event_cluster_locks
                WHERE node_id = ANY(v_dead_nodes)
            )
        )
    );
END;
$$;

COMMENT ON FUNCTION event_document_bus_cluster_supervisor IS
'Überwacht Cluster-Nodes, entfernt inaktive Nodes, gibt Locks frei und führt Leader-Failover durch.';
