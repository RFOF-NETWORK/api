-- api/compliance/events/compliance_event_list.sql
-- Modul: COMPLIANCE
-- Zweck: Filterbares, paginiertes Listing aller Compliance-Events

CREATE OR REPLACE FUNCTION compliance_event_list(
    p_filter JSONB DEFAULT '{}'::jsonb,   -- { event_type, entity_type, entity_id, compliance_type, compliance_status, from, to }
    p_limit  INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_params TEXT := '';
    v_result JSONB;
BEGIN
    -- 1. Basis-Query
    v_sql := '
        SELECT
            event_id,
            event_type,
            entity_type,
            entity_id,
            payload,
            created_at,
            updated_at
        FROM document_events
        WHERE event_type LIKE ''COMPLIANCE_%''
    ';

    -- 2. Dynamische Filter
    IF p_filter ? 'event_type' THEN
        v_sql := v_sql || ' AND event_type = ' || quote_literal(p_filter->>'event_type');
    END IF;

    IF p_filter ? 'entity_type' THEN
        v_sql := v_sql || ' AND entity_type = ' || quote_literal(p_filter->>'entity_type');
    END IF;

    IF p_filter ? 'entity_id' THEN
        v_sql := v_sql || ' AND entity_id = ' || quote_literal(p_filter->>'entity_id');
    END IF;

    IF p_filter ? 'compliance_type' THEN
        v_sql := v_sql || ' AND payload->>''compliance_type'' = ' || quote_literal(p_filter->>'compliance_type');
    END IF;

    IF p_filter ? 'compliance_status' THEN
        v_sql := v_sql || ' AND payload->>''compliance_status'' = ' || quote_literal(p_filter->>'compliance_status');
    END IF;

    IF p_filter ? 'from' THEN
        v_sql := v_sql || ' AND created_at >= ' || quote_literal(p_filter->>'from');
    END IF;

    IF p_filter ? 'to' THEN
        v_sql := v_sql || ' AND created_at <= ' || quote_literal(p_filter->>'to');
    END IF;

    -- 3. Sortierung + Pagination
    v_sql := v_sql || format(' ORDER BY created_at DESC LIMIT %s OFFSET %s', p_limit, p_offset);

    -- 4. Ergebnis aggregieren
    EXECUTE format('SELECT jsonb_agg(row_to_json(t)) FROM (%s) t', v_sql)
    INTO v_result;

    -- 5. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'filter', p_filter,
        'limit', p_limit,
        'offset', p_offset,
        'count', COALESCE(jsonb_array_length(v_result), 0),
        'items', COALESCE(v_result, '[]'::jsonb),
        'generated_at', now()
    );
END;
$$;

COMMENT ON FUNCTION compliance_event_list IS
'Listet Compliance-Events mit Filtern, Pagination und Query-Engine.';
