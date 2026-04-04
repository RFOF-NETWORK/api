CREATE OR REPLACE FUNCTION compliance_action_integrity()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_missing_compliance JSONB;
    v_broken_payload JSONB;
BEGIN
    SELECT jsonb_agg(action_id)
    INTO v_missing_compliance
    FROM compliance_actions a
    WHERE NOT EXISTS (
        SELECT 1 FROM compliance c WHERE c.compliance_id = a.compliance_id
    );

    SELECT jsonb_agg(action_id)
    INTO v_broken_payload
    FROM compliance_actions
    WHERE jsonb_typeof(payload) IS DISTINCT FROM 'object';

    RETURN jsonb_build_object(
        'missing_compliance_reference', COALESCE(v_missing_compliance, '[]'::jsonb),
        'broken_payload', COALESCE(v_broken_payload, '[]'::jsonb),
        'generated_at', now()
    );
END;
$$;
