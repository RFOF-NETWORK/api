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

-- Sharding-Funktion: verteilt Events deterministisch auf Cluster-Nodes

CREATE OR REPLACE FUNCTION event_document_bus_cluster_shard(
    p_event_id UUID
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_nodes TEXT[];
    v_index INT;
BEGIN
    -- 1. Aktive Nodes holen
    SELECT ARRAY(
        SELECT node_id
        FROM document_event_cluster_nodes
        WHERE last_seen > now() - INTERVAL '10 seconds'
        ORDER BY node_id
    )
    INTO v_nodes;

    IF array_length(v_nodes, 1) IS NULL THEN
        RETURN NULL;
    END IF;

    -- 2. Deterministisches Sharding
    v_index := (abs(hashtext(p_event_id::TEXT)) % array_length(v_nodes, 1)) + 1;

    RETURN v_nodes[v_index];
END;
$$;

COMMENT ON FUNCTION event_document_bus_cluster_shard IS
'Deterministische Sharding-Funktion für Events basierend auf Event-ID.';

-- Cluster-Lock für Event-Verarbeitung

CREATE OR REPLACE FUNCTION event_document_bus_cluster_lock(
    p_event_id UUID,
    p_node_id TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_locked BOOLEAN := FALSE;
BEGIN
    INSERT INTO document_event_cluster_locks (
        event_id,
        node_id,
        locked_at
    )
    VALUES (
        p_event_id,
        p_node_id,
        now()
    )
    ON CONFLICT (event_id)
    DO NOTHING;

    -- Prüfen, ob Lock erfolgreich
    SELECT (node_id = p_node_id)
    INTO v_locked
    FROM document_event_cluster_locks
    WHERE event_id = p_event_id;

    RETURN v_locked;
END;
$$;

COMMENT ON FUNCTION event_document_bus_cluster_lock IS
'Cluster-Lock: verhindert doppelte Verarbeitung desselben Events auf mehreren Nodes.';
