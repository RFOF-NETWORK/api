-- documents/events/document_event_bus_router.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Policy-gesteuerte automatische Weiterleitung im Event-Bus

CREATE OR REPLACE FUNCTION event_document_bus_router(
    p_event_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_policy JSONB;
    v_action TEXT;
    v_result JSONB := '{}'::jsonb;
BEGIN
    -- 1. Policy für dieses Event bestimmen
    v_policy := event_document_bus_policy(p_event_id);
    v_action := v_policy->>'action';

    -- 2. Aktion basierend auf Policy ausführen
    CASE v_action

        WHEN 'PROCESS' THEN
            v_result := event_document_bus(
                'PROCESS',
                p_event_id
            );

        WHEN 'RETRY' THEN
            v_result := event_document_bus(
                'RETRY',
                p_event_id,
                jsonb_build_object('reason', v_policy->>'reason')
            );

        WHEN 'DEADLETTER' THEN
            v_result := event_document_bus(
                'DEADLETTER',
                p_event_id,
                jsonb_build_object(
                    'reason', v_policy->>'reason',
                    'metadata', v_policy
                )
            );

        WHEN 'ROUTE_OVERRIDE' THEN
            v_result := jsonb_build_object(
                'action', 'ROUTE_OVERRIDE',
                'event_id', p_event_id,
                'route_to', v_policy->>'route_to'
            );

        WHEN 'BROADCAST' THEN
            v_result := event_document_bus(
                'BROADCAST',
                p_event_id
            );

        ELSE
            v_result := jsonb_build_object(
                'error', 'UNKNOWN_POLICY_ACTION',
                'policy', v_policy
            );
    END CASE;

    -- 3. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'event_id', p_event_id,
        'policy', v_policy,
        'result', v_result
    );
END;
$$;

COMMENT ON FUNCTION event_document_bus_router IS
'Policy-gesteuerter Router, der automatisch die korrekte Event-Bus-Aktion auswählt.';
