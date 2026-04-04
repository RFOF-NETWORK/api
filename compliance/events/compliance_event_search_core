CREATE OR REPLACE FUNCTION compliance_event_search_core(p_query TEXT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT jsonb_agg(row_to_json(t))
    FROM (
        SELECT *
        FROM document_events
        WHERE to_tsvector('simple', payload::text)
              @@ plainto_tsquery('simple', p_query)
        ORDER BY created_at DESC
    ) t;
$$;
