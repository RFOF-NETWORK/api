-- api/compliance/events/compliance_event_heatmap.sql
-- Modul: COMPLIANCE
-- Zweck: Heatmap-Aggregationen für Compliance-Events (Zeit, Typ, Status)

CREATE OR REPLACE FUNCTION compliance_event_heatmap(
    p_window TEXT DEFAULT 'DAY'   -- HOUR | DAY | WEEK
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_time_bucket TEXT;
    v_by_time JSONB;
    v_by_event_type JSONB;
    v_by_compliance_type JSONB;
    v_by_status JSONB;
    v_by_entity_type JSONB;
BEGIN
    -- 1. Zeitfenster bestimmen
    CASE upper(p_window)
        WHEN 'HOUR' THEN v_time_bucket := 'DATE_TRUNC(''hour'', created_at)';
        WHEN 'WEEK' THEN v_time_bucket := 'DATE_TRUNC(''week'', created_at)';
        ELSE v_time_bucket := 'DATE_TRUNC(''day'', created_at)';
    END CASE;

    -- 2. Heatmap: Zeitaggregation
    EXECUTE format(
        'SELECT jsonb_agg(jsonb_build_object(
            ''bucket'', bucket,
            ''count'', count
        ))
        FROM (
            SELECT %s AS bucket, COUNT(*)
            FROM document_events
            WHERE event_type LIKE ''COMPLIANCE_%%''
            GROUP BY %s
            ORDER BY bucket
        ) t',
        v_time_bucket, v_time_bucket
    )
    INTO v_by_time;

    -- 3. Heatmap: event_type
    SELECT jsonb_agg(jsonb_build_object('event_type', event_type, 'count', count))
    INTO v_by_event_type
    FROM (
        SELECT event_type, COUNT(*)
        FROM document_events
        WHERE event_type LIKE 'COMPLIANCE_%'
        GROUP BY event_type
        ORDER BY count DESC
    ) t;

    -- 4. Heatmap: compliance_type
    SELECT jsonb_agg(jsonb_build_object('compliance_type', compliance_type, 'count', count))
    INTO v_by_compliance_type
    FROM (
        SELECT payload->>'compliance_type' AS compliance_type, COUNT(*)
        FROM document_events
        WHERE event_type LIKE 'COMPLIANCE_%'
        GROUP BY payload->>'compliance_type'
        ORDER BY count DESC
    ) t;

    -- 5. Heatmap: compliance_status
    SELECT jsonb_agg(jsonb_build_object('compliance_status', compliance_status, 'count', count))
    INTO v_by_status
    FROM (
        SELECT payload->>'compliance_status' AS compliance_status, COUNT(*)
        FROM document_events
        WHERE event_type LIKE 'COMPLIANCE_%'
        GROUP BY payload->>'compliance_status'
        ORDER BY count DESC
    ) t;

    -- 6. Heatmap: entity_type
    SELECT jsonb_agg(jsonb_build_object('entity_type', entity_type, 'count', count))
    INTO v_by_entity_type
    FROM (
        SELECT entity_type, COUNT(*)
        FROM document_events
        WHERE event_type LIKE 'COMPLIANCE_%'
        GROUP BY entity_type
        ORDER BY count DESC
    ) t;

    -- 7. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'window', p_window,
        'time_heatmap', COALESCE(v_by_time, '[]'::jsonb),
        'event_type_heatmap', COALESCE(v_by_event_type, '[]'::jsonb),
        'compliance_type_heatmap', COALESCE(v_by_compliance_type, '[]'::jsonb),
        'status_heatmap', COALESCE(v_by_status, '[]'::jsonb),
        'entity_type_heatmap', COALESCE(v_by_entity_type, '[]'::jsonb),
        'generated_at', now()
    );
END;
$$;

COMMENT ON FUNCTION compliance_event_heatmap IS
'Erzeugt Heatmap-Aggregationen für Compliance-Events (Zeit, Typ, Status, Entity).';
