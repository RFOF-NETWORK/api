-- documents/events/document_event_bus.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Zentrale Event-Bus-Abstraktion für alle Event-Operationen

CREATE OR REPLACE FUNCTION event_document_bus(
    p_action TEXT,
    p_event_id UUID DEFAULT NULL,
    p_payload JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB := '{}'::jsonb;
BEGIN
    CASE p_action

        WHEN 'EMIT' THEN
            v_result := jsonb_build_object(
                'action', 'EMIT',
                'event_id', event_document_emit(
                    p_payload->>'document_id',
                    p_payload->>'event_type',
                    p_payload->'data'
                )
            );

        WHEN 'DISPATCH' THEN
            v_result := jsonb_build_object(
                'action', 'DISPATCH',
                'batch', event_document_dispatch(
                    COALESCE((p_payload->>'limit')::INT, 100)
                )
            );

        WHEN 'PROCESS' THEN
            v_result := jsonb_build_object(
                'action', 'PROCESS',
                'handler', event_document_process(p_event_id)
            );

        WHEN 'PROCESS_BATCH' THEN
            v_result := jsonb_build_object(
                'action', 'PROCESS_BATCH',
                'batch', event_document_process_batch(
                    COALESCE((p_payload->>'limit')::INT, 100)
                )
            );

        WHEN 'BROADCAST' THEN
            v_result := jsonb_build_object(
                'action', 'BROADCAST',
                'result', event_document_broadcast(p_event_id)
            );

        WHEN 'RETRY' THEN
            PERFORM event_document_retry(
                p_event_id,
                p_payload->>'reason'
            );
            v_result := jsonb_build_object('action', 'RETRY', 'event_id', p_event_id);

        WHEN 'DEADLETTER' THEN
            PERFORM event_document_deadletter(
                p_event_id,
                p_payload->>'reason',
                p_payload->'metadata'
            );
            v_result := jsonb_build_object('action', 'DEADLETTER', 'event_id', p_event_id);

        WHEN 'REPLAY' THEN
            PERFORM event_document_replay(
                p_event_id,
                p_payload->>'reason'
            );
            v_result := jsonb_build_object('action', 'REPLAY', 'event_id', p_event_id);

        WHEN 'METRICS' THEN
            v_result := jsonb_build_object(
                'action', 'METRICS',
                'metrics', event_document_metrics()
            );

        ELSE
            v_result := jsonb_build_object(
                'error', 'UNKNOWN_ACTION',
                'action', p_action
            );
    END CASE;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION event_document_bus IS
'Zentrale Event-Bus-Abstraktion, die alle Event-Operationen über eine einheitliche API kapselt.';
