CREATE OR REPLACE FUNCTION compliance_action_escalate(
    p_action_id UUID,
    p_level INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE compliance_actions
    SET escalation_level = p_level,
        updated_at = now()
    WHERE action_id = p_action_id;

    RETURN jsonb_build_object(
        'action_id', p_action_id,
        'escalation_level', p_level,
        'updated_at', now()
    );
END;
$$;
