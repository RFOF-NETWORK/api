CREATE OR REPLACE FUNCTION compliance_action_close(
    p_action_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE compliance_actions
    SET status = 'CLOSED',
        updated_at = now()
    WHERE action_id = p_action_id;

    RETURN jsonb_build_object(
        'action_id', p_action_id,
        'status', 'CLOSED',
        'updated_at', now()
    );
END;
$$;
