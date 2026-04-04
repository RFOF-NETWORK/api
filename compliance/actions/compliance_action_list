CREATE OR REPLACE FUNCTION compliance_action_list(
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
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
        ORDER BY created_at DESC
        LIMIT p_limit OFFSET p_offset
    ) t;

    RETURN jsonb_build_object(
        'limit', p_limit,
        'offset', p_offset,
        'items', COALESCE(v_items, '[]'::jsonb)
    );
END;
$$;
