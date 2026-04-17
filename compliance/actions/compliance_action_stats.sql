CREATE OR REPLACE FUNCTION compliance_action_stats()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
    v_by_status JSONB;
    v_by_type JSONB;
BEGIN
    SELECT COUNT(*) INTO v_total FROM compliance_actions;

    SELECT jsonb_agg(jsonb_build_object('status', status, 'count', count))
    INTO v_by_status
    FROM (
        SELECT status, COUNT(*) FROM compliance_actions GROUP BY status
    ) t;

    SELECT jsonb_agg(jsonb_build_object('action_type', action_type, 'count', count))
    INTO v_by_type
    FROM (
        SELECT action_type, COUNT(*) FROM compliance_actions GROUP BY action_type
    ) t;

    RETURN jsonb_build_object(
        'total', v_total,
        'by_status', COALESCE(v_by_status, '[]'::jsonb),
        'by_type', COALESCE(v_by_type, '[]'::jsonb)
    );
END;
$$;
