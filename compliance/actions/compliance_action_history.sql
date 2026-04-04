CREATE OR REPLACE FUNCTION compliance_action_history(
    p_action_id UUID
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
        FROM compliance_action_history
        WHERE action_id = p_action_id
        ORDER BY created_at DESC
    ) t;

    RETURN jsonb_build_object(
        'action_id', p_action_id,
        'history', COALESCE(v_items, '[]'::jsonb)
    );
END;
$$;
