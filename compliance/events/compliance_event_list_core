CREATE OR REPLACE FUNCTION compliance_event_list_core(p_limit INT DEFAULT 50, p_offset INT DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT jsonb_agg(row_to_json(t))
    FROM (
        SELECT *
        FROM document_events
        ORDER BY created_at DESC
        LIMIT p_limit OFFSET p_offset
    ) t;
$$;
