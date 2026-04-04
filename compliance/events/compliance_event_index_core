CREATE OR REPLACE FUNCTION compliance_event_index_core()
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT jsonb_build_object(
        'total', COUNT(*),
        'by_type', (
            SELECT jsonb_agg(jsonb_build_object('event_type', event_type, 'count', count))
            FROM (
                SELECT event_type, COUNT(*) FROM document_events GROUP BY event_type
            ) x
        )
    )
    FROM document_events;
$$;
