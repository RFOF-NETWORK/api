CREATE OR REPLACE FUNCTION compliance_action_create(
    p_compliance_id UUID,
    p_action_type TEXT,
    p_payload JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_action_id UUID := gen_random_uuid();
BEGIN
    INSERT INTO compliance_actions (
        action_id,
        compliance_id,
        action_type,
        payload,
        status,
        created_at,
        updated_at
    )
    VALUES (
        v_action_id,
        p_compliance_id,
        p_action_type,
        p_payload,
        'OPEN',
        now(),
        now()
    );

    RETURN jsonb_build_object(
        'action_id', v_action_id,
        'status', 'OPEN',
        'created_at', now()
    );
END;
$$;
