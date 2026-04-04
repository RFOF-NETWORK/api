-- documents/events/document_event_bus_cluster.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Cluster-Koordination (Leader-Election, Heartbeats, Locking, Sharding)

CREATE OR REPLACE FUNCTION event_document_bus_cluster_heartbeat(
    p_node_id TEXT,
    p_capacity INT DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_now TIMESTAMP := now();
    v_is_leader BOOLEAN := FALSE;
    v_leader TEXT;
BEGIN
    -- 1. Node-Heartbeat aktualisieren oder eintragen
    INSERT INTO document_event_cluster_nodes (
        node_id,
        last_seen,
        capacity,
        created_at
    )
    VALUES (
        p_node_id,
        v_now,
        p_capacity,
        v_now
    )
    ON CONFLICT (node_id)
    DO UPDATE SET
        last_seen = EXCLUDED.last_seen,
        capacity  = EXCLUDED.capacity;

    -- 2. Leader bestimmen (Node mit frühestem created_at)
    SELECT node_id
    INTO v_leader
    FROM document_event_cluster_nodes
    ORDER BY created_at ASC
    LIMIT 1;

    v_is_leader := (v_leader = p_node_id);

    -- 3. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'node_id', p_node_id,
        'is_leader', v_is_leader,
        'leader_node', v_leader,
        'timestamp', v_now
    );
END;
$$;

COMMENT ON FUNCTION event_document_bus_cluster_heartbeat IS
'Cluster-Heartbeat: registriert Nodes, aktualisiert Status und bestimmt Leader.';
