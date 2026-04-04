-- api/compliance/events/compliance_event_kpi.sql
-- Modul: COMPLIANCE
-- Zweck: High-Level KPIs für Compliance-Events

CREATE OR REPLACE FUNCTION compliance_event_kpi()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
    v_deadletter INTEGER;
    v_retry INTEGER;
    v_retry_events INTEGER;
    v_success INTEGER;
    v_today INTEGER;
    v_last_hour INTEGER;
    v_kpi JSONB;
BEGIN
    -- 1. Gesamtanzahl Compliance-Events
    SELECT COUNT(*)
    INTO v_total
    FROM document_events
    WHERE event_type LIKE 'COMPLIANCE_%';

    -- 2. Deadletter-Anzahl
    SELECT COUNT(*)
    INTO v_deadletter
    FROM document_event_deadletter_log;

    -- 3. Retry-Logs
    SELECT COUNT(*)
    INTO v_retry
    FROM document_event_retry_log;

    -- Anzahl Events, die mindestens 1 Retry hatten
    SELECT COUNT(DISTINCT event_id)
    INTO v_retry_events
    FROM document_event_retry_log;

    -- 4. Erfolgreiche Events (keine Deadletter, keine Retries)
    SELECT COUNT(*)
    INTO v_success
    FROM document_events e
    WHERE e.event_type LIKE 'COMPLIANCE_%'
      AND NOT EXISTS (
          SELECT 1 FROM document_event_deadletter_log d WHERE d.event_id = e.event_id
      )
      AND NOT EXISTS (
          SELECT 1 FROM document_event_retry_log r WHERE r.event_id = e.event_id
      );

    -- 5. Throughput: Heute
    SELECT COUNT(*)
    INTO v_today
    FROM document_events
    WHERE event_type LIKE 'COMPLIANCE_%'
      AND created_at::date = CURRENT_DATE;

    -- 6. Throughput: Letzte Stunde
    SELECT COUNT(*)
    INTO v_last_hour
    FROM document_events
    WHERE event_type LIKE 'COMPLIANCE_%'
      AND created_at >= now() - INTERVAL '1 hour';

    -- 7. KPI-Objekt bauen
    v_kpi := jsonb_build_object(
        'total_events', v_total,
        'success_events', v_success,
        'retry_events', v_retry_events,
        'deadletter_events', v_deadletter,
        'retry_logs', v_retry,
        'sla_rate', CASE WHEN v_total = 0 THEN 1 ELSE (v_success::numeric / v_total) END,
        'error_rate', CASE WHEN v_total = 0 THEN 0 ELSE (v_deadletter::numeric / v_total) END,
        'retry_rate', CASE WHEN v_total = 0 THEN 0 ELSE (v_retry_events::numeric / v_total) END,
        'first_pass_success_rate', CASE WHEN v_total = 0 THEN 1 ELSE (v_success::numeric / v_total) END,
        'throughput_today', v_today,
        'throughput_last_hour', v_last_hour,
        'generated_at', now()
    );

    RETURN v_kpi;
END;
$$;

COMMENT ON FUNCTION compliance_event_kpi IS
'Erzeugt High-Level KPIs für Compliance-Events (SLA, Error, Retry, Throughput).';
