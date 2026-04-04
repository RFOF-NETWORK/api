CREATE OR REPLACE FUNCTION compliance_action_assign(
    p_action_id UUID,
    p_assignee TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE compliance_actions
    SET assignee = p_assignee,
        updated_at = now()
    WHERE action_id = p_action_id;

    RETURN jsonb_build_object(
        'action_id', p_action_id,
        'assignee', p_assignee,
        'updated_at', now()
    );
END;
$$;
