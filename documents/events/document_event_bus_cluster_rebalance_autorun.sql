-- documents/events/document_event_bus_cluster_rebalance_autorun.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Autonomer Rebalancer (Supervisor + Rebalance in Endlosschleife)

CREATE OR REPLACE FUNCTION event_document_bus_cluster_rebalance_autorun(
    p_interval_seconds INT DEFAULT 5
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_supervisor JSONB;
    v_rebalance JSONB;
BEGIN
    LOOP
        -- 1. Cluster-Supervisor ausführen (Node-Cleanup, Lock-Release, Leader-Failover)
        v_supervisor := event_document_bus_cluster_supervisor();

        -- 2. Rebalancing ausführen (Shard-Neuberechnung, Lock-Bereinigung)
        v_rebalance := event_document_bus_cluster_rebalance();

        -- 3. Optional: Logging/Audit (falls Tabelle existiert)
        INSERT INTO document_event_cluster_rebalance_audit (
            audit_id,
            supervisor_result,
            rebalance_result,
            created_at
        )
        VALUES (
            gen_random_uuid(),
            v_supervisor,
            v_rebalance,
            now()
        )
        ON CONFLICT DO NOTHING;

        -- 4. Warten bis zum nächsten Zyklus
        PERFORM pg_sleep(p_interval_seconds);
    END LOOP;
END;
$$;

COMMENT ON FUNCTION event_document_bus_cluster_rebalance_autorun IS
'Autonomer Rebalancer: führt Supervisor + Rebalance periodisch aus und hält den Cluster stabil.';
