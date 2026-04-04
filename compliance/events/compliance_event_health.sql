CREATE OR REPLACE FUNCTION compliance_event_health()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
    v_deadletter INTEGER;
    v_retry INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM document_events;
    SELECT COUNT(*) INTO v_deadletter FROM document_event_deadletter_log;
    SELECT COUNT(*) INTO v_retry FROM document_event_retry_log;

    RETURN jsonb_build_object(
        'total_events', v_total,
        'deadletter', v_deadletter,
        'retry', v_retry,
        'healthy', (v_deadletter = 0 AND v_retry < (v_total * 0.1))
    );
END;
$$;
