-- api/compliance/events/compliance_event_matrix.sql
-- Modul: COMPLIANCE
-- Zweck: Multidimensionale Matrix-Aggregation über Compliance-Events

CREATE OR REPLACE FUNCTION compliance_event_matrix(
    p_window TEXT DEFAULT 'DAY'   -- HOUR | DAY | WEEK
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_bucket TEXT;
    v_matrix JSONB;
BEGIN
    -- 1. Zeitbucket bestimmen
    CASE upper(p_window)
        WHEN 'HOUR' THEN v_bucket := 'DATE_TRUNC(''hour'', created_at)';
        WHEN 'WEEK' THEN v_bucket := 'DATE_TRUNC(''week'', created_at)';
        ELSE v_bucket := 'DATE_TRUNC(''day'', created_at)';
    END CASE;

    -- 2. Matrix aggregieren
    EXECUTE format(
        'SELECT jsonb_agg(jsonb_build_object(
            ''bucket'', bucket,
            ''event_type'', event_type,
            ''compliance_type'', compliance_type,
            ''compliance_status'', compliance_status,
            ''entity_type'', entity_type,
            ''count'', count
        ))
        FROM (
            SELECT
                %s AS bucket,
                event_type,
                payload->>''compliance_type'' AS compliance_type,
                payload->>''compliance_status'' AS compliance_status,
                entity_type,
                COUNT(*) AS count
            FROM document_events
            WHERE event_type LIKE ''COMPLIANCE_%%''
            GROUP BY bucket, event_type, compliance_type, compliance_status, entity_type
            ORDER BY bucket, event_type, compliance_type, compliance_status, entity_type
        ) t',
        v_bucket
    )
    INTO v_matrix;

    -- 3. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'window', p_window,
        'matrix', COALESCE(v_matrix, '[]'::jsonb),
        'generated_at', now()
    );
END;
$$;

COMMENT ON FUNCTION compliance_event_matrix IS
'Erzeugt eine multidimensionale Matrix-Aggregation über Compliance-Events (Zeit × Typ × Status × Entity).';
