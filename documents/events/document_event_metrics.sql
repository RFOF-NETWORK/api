-- documents/events/document_event_metrics.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Liefert systemweite Event-Metriken für Monitoring und Observability

CREATE OR REPLACE FUNCTION event_document_metrics()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total            BIGINT;
    v_pending          BIGINT;
    v_dispatched       BIGINT;
    v_processed        BIGINT;
    v_failed           BIGINT;
    v_deadletter       BIGINT;
    v_avg_process_ms   NUMERIC;
BEGIN
    -- Grundzahlen
    SELECT COUNT(*) INTO v_total FROM document_events;
    SELECT COUNT(*) INTO v_pending FROM document_events WHERE dispatched_at IS NULL;
    SELECT COUNT(*) INTO v_dispatched FROM document_events WHERE dispatched_at IS NOT NULL AND processed_at IS NULL;
    SELECT COUNT(*) INTO v_processed FROM document_events WHERE processed_at IS NOT NULL AND status = 'SUCCESS';
    SELECT COUNT(*) INTO v_failed FROM document_events WHERE status = 'FAILED';
    SELECT COUNT(*) INTO v_deadletter FROM document_events WHERE status = 'DEADLETTER';

    -- Durchschnittliche Verarbeitungszeit
    SELECT AVG(EXTRACT(MILLISECOND FROM (processed_at - dispatched_at)))
    INTO v_avg_process_ms
    FROM document_events
    WHERE processed_at IS NOT NULL
      AND dispatched_at IS NOT NULL;

    RETURN jsonb_build_object(
        'total_events', v_total,
        'pending_events', v_pending,
        'dispatched_events', v_dispatched,
        'processed_events', v_processed,
        'failed_events', v_failed,
        'deadletter_events', v_deadletter,
        'avg_processing_ms', COALESCE(v_avg_process_ms, 0)
    );
END;
$$;

COMMENT ON FUNCTION event_document_metrics IS
'Gibt systemweite Event-Metriken für Monitoring und Observability zurück.';
