-- api/compliance/events/compliance_event_stats.sql
-- Modul: COMPLIANCE
-- Zweck: Globale Statistiken, KPIs und Aggregationen für Compliance-Events

CREATE OR REPLACE FUNCTION compliance_event_stats()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_events INTEGER;
    v_by_type JSONB;
    v_by_compliance_type JSONB;
    v_by_status JSONB;
    v_by_entity_type JSONB;
    v_daily JSONB;
    v_retry JSONB;
    v_deadletter INTEGER;
BEGIN
    -- 1. Gesamtanzahl Compliance-Events
    SELECT COUNT(*)
    INTO v_total_events
    FROM document_events
    WHERE event_type LIKE 'COMPLIANCE_%';

    -- 2. Events pro event_type
    SELECT jsonb_agg(jsonb_build_object('event_type', event_type, 'count', count))
    INTO v_by_type
    FROM (
        SELECT event_type, COUNT(*)
        FROM document_events
        WHERE event_type LIKE 'COMPLIANCE_%'
        GROUP BY event_type
        ORDER BY count DESC
    ) t;

    -- 3. Events pro compliance_type
    SELECT jsonb_agg(jsonb_build_object('compliance_type', compliance_type, 'count', count))
    INTO v_by_compliance_type
    FROM (
        SELECT payload->>'compliance_type' AS compliance_type, COUNT(*)
        FROM document_events
        WHERE event_type LIKE 'COMPLIANCE_%'
        GROUP BY payload->>'compliance_type'
        ORDER BY count DESC
    ) t;

    -- 4. Events pro compliance_status
    SELECT jsonb_agg(jsonb_build_object('compliance_status', compliance_status, 'count', count))
    INTO v_by_status
    FROM (
        SELECT payload->>'compliance_status' AS compliance_status, COUNT(*)
        FROM document_events
        WHERE event_type LIKE 'COMPLIANCE_%'
        GROUP BY payload->>'compliance_status'
        ORDER BY count DESC
    ) t;

    -- 5. Events pro entity_type
    SELECT jsonb_agg(jsonb_build_object('entity_type', entity_type, 'count', count))
    INTO v_by_entity_type
    FROM (
        SELECT entity_type, COUNT(*)
        FROM document_events
        WHERE event_type LIKE 'COMPLIANCE_%'
        GROUP BY entity_type
        ORDER BY count DESC
    ) t;

    -- 6. Tägliche Aggregation
    SELECT jsonb_agg(jsonb_build_object('date', day, 'count', count))
    INTO v_daily
    FROM (
        SELECT DATE(created_at) AS day, COUNT(*)
        FROM document_events
        WHERE event_type LIKE 'COMPLIANCE_%'
        GROUP BY DATE(created_at)
        ORDER BY day DESC
    ) t;

    -- 7. Retry-Verteilung
    SELECT jsonb_agg(jsonb_build_object('retry_count', retry_count, 'count', count))
    INTO v_retry
    FROM (
        SELECT (payload->>'retry_count')::int AS retry_count, COUNT(*)
        FROM document_event_retry_log
        GROUP BY (payload->>'retry_count')::int
        ORDER BY retry_count
    ) t;

    -- 8. Deadletter-Anzahl
    SELECT COUNT(*)
    INTO v_deadletter
    FROM document_event_deadletter_log;

    -- 9. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'total_events', v_total_events,
        'by_event_type', COALESCE(v_by_type, '[]'::jsonb),
        'by_compliance_type', COALESCE(v_by_compliance_type, '[]'::jsonb),
        'by_compliance_status', COALESCE(v_by_status, '[]'::jsonb),
        'by_entity_type', COALESCE(v_by_entity_type, '[]'::jsonb),
        'daily', COALESCE(v_daily, '[]'::jsonb),
        'retry_distribution', COALESCE(v_retry, '[]'::jsonb),
        'deadletter_count', v_deadletter,
        'stats_generated_at', now()
    );
END;
$$;

COMMENT ON FUNCTION compliance_event_stats IS
'Aggregiert globale Statistiken, KPIs und Verteilungen für Compliance-Events.';
