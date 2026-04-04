CREATE OR REPLACE FUNCTION compliance_action_kpi()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
    v_closed INTEGER;
    v_open INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM compliance_actions;
    SELECT COUNT(*) INTO v_closed FROM compliance_actions WHERE status = 'CLOSED';
    SELECT COUNT(*) INTO v_open FROM compliance_actions WHERE status = 'OPEN';

    RETURN jsonb_build_object(
        'total', v_total,
        'open', v_open,
        'closed', v_closed,
        'closure_rate', CASE WHEN v_total = 0 THEN 0 ELSE v_closed::numeric / v_total END
    );
END;
$$;
