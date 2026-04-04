-- api/compliance/events/compliance_event_purge.sql
-- Modul: COMPLIANCE
-- Zweck: Löscht alte Compliance-Events und zugehörige Logs gemäß Retention-Policy

CREATE OR REPLACE FUNCTION compliance_event_purge(
    p_retention_days INTEGER DEFAULT 90
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_cutoff TIMESTAMP;
    v_deleted_events INTEGER := 0;
    v_deleted_stream INTEGER := 0;
    v_deleted_metrics INTEGER := 0;
    v_deleted_retry INTEGER := 0;
    v_deleted_deadletter INTEGER := 0;
BEGIN
    -- 1. Cutoff berechnen
    v_cutoff := now() - (p_retention_days || ' days')::INTERVAL;

    -- 2. Stream-Logs löschen
    DELETE FROM document_event_stream_log
    WHERE created_at < v_cutoff;
    GET DIAGNOSTICS v_deleted_stream = ROW_COUNT;

    -- 3. Metrics-Logs löschen
    DELETE FROM document_event_metrics_log
    WHERE created_at < v_cutoff;
    GET DIAGNOSTICS v_deleted_metrics = ROW_COUNT;

    -- 4. Retry-Logs löschen
    DELETE FROM document_event_retry_log
    WHERE created_at < v_cutoff;
    GET DIAGNOSTICS v_deleted_retry = ROW_COUNT;

    -- 5. Deadletter-Logs löschen
    DELETE FROM document_event_deadletter_log
    WHERE created_at < v_cutoff;
    GET DIAGNOSTICS v_deleted_deadletter = ROW_COUNT;

    -- 6. Events selbst löschen
    DELETE FROM document_events
    WHERE created_at < v_cutoff
      AND event_type LIKE 'COMPLIANCE_%';
    GET DIAGNOSTICS v_deleted_events = ROW_COUNT;

    -- 7. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'retention_days', p_retention_days,
        'cutoff', v_cutoff,
        'deleted_events', v_deleted_events,
        'deleted_stream_logs', v_deleted_stream,
        'deleted_metrics_logs', v_deleted_metrics,
        'deleted_retry_logs', v_deleted_retry,
        'deleted_deadletter_logs', v_deleted_deadletter,
        'purged_at', now()
    );
END;
$$;

COMMENT ON FUNCTION compliance_event_purge IS
'Löscht alte Compliance-Events und Logs gemäß Retention-Policy.';
