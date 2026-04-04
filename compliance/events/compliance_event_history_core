CREATE OR REPLACE FUNCTION compliance_event_history_core(p_compliance_id UUID)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT jsonb_agg(row_to_json(t))
    FROM (
        SELECT *
        FROM document_events
        WHERE payload->>'compliance_id' = p_compliance_id::text
        ORDER BY created_at DESC
    ) t;
$$;
