CREATE OR REPLACE FUNCTION compliance_event_status_core(p_event_id UUID)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT payload->>'compliance_status'
    FROM document_events
    WHERE event_id = p_event_id;
$$;
