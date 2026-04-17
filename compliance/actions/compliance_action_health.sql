CREATE OR REPLACE FUNCTION compliance_action_health()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
    v_open INTEGER;
    v_pressure NUMERIC;
BEGIN
    SELECT COUNT(*) INTO v_total FROM compliance_actions;
    SELECT COUNT(*) INTO v_open FROM compliance_actions WHERE status = 'OPEN';

    v_pressure := CASE WHEN v_total = 0 THEN 0 ELSE v_open::numeric / v_total END;

    RETURN jsonb_build_object(
        'total', v_total,
        'open', v_open,
        'pressure', v_pressure,
        'healthy', v_pressure < 0.7
    );
END;
$$;
