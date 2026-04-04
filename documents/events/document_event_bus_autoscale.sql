-- documents/events/document_event_bus_autoscale.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Automatische Skalierung der Event-Worker basierend auf Systemmetriken

CREATE OR REPLACE FUNCTION event_document_bus_autoscale()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_monitor JSONB;
    v_queue_depth BIGINT;
    v_failures BIGINT;
    v_deadletters BIGINT;
    v_latency NUMERIC;
    v_scale_action TEXT := 'NONE';
    v_scale_factor INT := 0;
BEGIN
    -- 1. Monitoring-Daten laden
    v_monitor := event_document_bus_monitor();

    v_queue_depth := (v_monitor->>'queue_depth')::BIGINT;
    v_failures    := (v_monitor->>'failures')::BIGINT;
    v_deadletters := (v_monitor->>'deadletters')::BIGINT;
    v_latency     := (v_monitor->>'avg_latency_ms')::NUMERIC;

    -- 2. Skalierungslogik

    -- Hochskalieren bei hoher Last
    IF v_queue_depth > 500 OR v_latency > 200 THEN
        v_scale_action := 'SCALE_UP';
        v_scale_factor := CEIL(v_queue_depth / 500.0);

    -- Runterskalieren bei geringer Last
    ELSIF v_queue_depth < 20 AND v_latency < 50 THEN
        v_scale_action := 'SCALE_DOWN';
        v_scale_factor := 1;

    -- Kritischer Zustand → Notfall-Hochskalierung
    ELSIF v_failures > 50 OR v_deadletters > 10 THEN
        v_scale_action := 'EMERGENCY_SCALE_UP';
        v_scale_factor := 3;
    END IF;

    -- 3. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'action', v_scale_action,
        'scale_factor', v_scale_factor,
        'queue_depth', v_queue_depth,
        'failures', v_failures,
        'deadletters', v_deadletters,
        'latency_ms', v_latency,
        'timestamp', now()
    );
END;
$$;

COMMENT ON FUNCTION event_document_bus_autoscale IS
'Automatische Skalierung der Event-Worker basierend auf Queue-Tiefe, Fehlerquote und Latenz.';
