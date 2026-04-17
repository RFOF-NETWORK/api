CREATE OR REPLACE FUNCTION compliance_action_search(
    p_query TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items JSONB;
BEGIN
    SELECT jsonb_agg(row_to_json(t))
    INTO v_items
    FROM (
        SELECT *
        FROM compliance_actions
        WHERE to_tsvector('simple', payload::text)
              @@ plainto_tsquery('simple', p_query)
        ORDER BY created_at DESC
    ) t;

    RETURN jsonb_build_object(
        'query', p_query,
        'items', COALESCE(v_items, '[]'::jsonb)
    );
END;
$$;
