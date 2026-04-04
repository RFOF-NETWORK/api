-- api/compliance/events/compliance_event_integrity.sql
-- Modul: COMPLIANCE
-- Zweck: Integritätsprüfung für Compliance-Events (Payload, Referenzen, Chains)

CREATE OR REPLACE FUNCTION compliance_event_integrity()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_missing_compliance JSONB;
    v_broken_payload JSONB;
    v_missing_logs JSONB;
    v_deadletter_mismatch JSONB;
    v_retry_mismatch JSONB;
    v_integrity JSONB;
BEGIN
    -- 1. Events mit fehlender Compliance-Referenz
    SELECT jsonb_agg(event_id)
    INTO v_missing_compliance
    FROM (
        SELECT e.event_id
        FROM document_events e
        WHERE e.event_type LIKE 'COMPLIANCE_%'
          AND (
              e.payload->>'compliance_id' IS NULL
              OR NOT EXISTS (
                    SELECT 1
                    FROM compliance c
                    WHERE c.compliance_id = (e.payload->>'compliance_id')::uuid
              )
          )
    ) t;

    -- 2. Events mit beschädigter Payload (nicht-JSON oder fehlende Schlüssel)
    SELECT jsonb_agg(event_id)
    INTO v_broken_payload
    FROM (
        SELECT e.event_id
        FROM document_events e
        WHERE e.event_type LIKE 'COMPLIANCE_%'
          AND (
              jsonb_typeof(e.payload) IS DISTINCT FROM 'object'
              OR NOT (e.payload ? 'compliance_type')
              OR NOT (e.payload ? 'compliance_status')
          )
    ) t;

    -- 3. Events ohne vollständige Log-Kette
    SELECT jsonb_agg(event_id)
    INTO v_missing_logs
    FROM (
        SELECT e.event_id
        FROM document_events e
        WHERE e.event_type LIKE 'COMPLIANCE_%'
          AND NOT EXISTS (SELECT 1 FROM document_event_route_log r WHERE r.event_id = e.event_id)
          AND NOT EXISTS (SELECT 1 FROM document_event_dispatch_log d WHERE d.event_id = e.event_id)
          AND NOT EXISTS (SELECT 1 FROM document_event_bus_log b WHERE b.event_id = e.event_id)
          AND NOT EXISTS (SELECT 1 FROM document_event_stream_log s WHERE s.event_id = e.event_id)
    ) t;

    -- 4. Deadletter-Mismatch (Event im Deadletter, aber Status nicht ERROR)
    SELECT jsonb_agg(event_id)
    INTO v_deadletter_mismatch
    FROM (
        SELECT d.event_id
        FROM document_event_deadletter_log d
        JOIN document_events e ON e.event_id = d.event_id
        WHERE e.payload->>'compliance_status' NOT IN ('ERROR', 'FAILED')
    ) t;

    -- 5. Retry-Mismatch (Retry-Logs existieren, aber Event hat SUCCESS)
    SELECT jsonb_agg(event_id)
    INTO v_retry_mismatch
    FROM (
        SELECT DISTINCT r.event_id
        FROM document_event_retry_log r
        JOIN document_events e ON e.event_id = r.event_id
        WHERE e.payload->>'compliance_status' = 'SUCCESS'
    ) t;

    -- 6. Ergebnisobjekt
    v_integrity := jsonb_build_object(
        'missing_compliance_reference', COALESCE(v_missing_compliance, '[]'::jsonb),
        'broken_payload', COALESCE(v_broken_payload, '[]'::jsonb),
        'missing_logs', COALESCE(v_missing_logs, '[]'::jsonb),
        'deadletter_mismatch', COALESCE(v_deadletter_mismatch, '[]'::jsonb),
        'retry_mismatch', COALESCE(v_retry_mismatch, '[]'::jsonb),
        'integrity_generated_at', now()
    );

    RETURN v_integrity;
END;
$$;

COMMENT ON FUNCTION compliance_event_integrity IS
'Prüft die Integrität aller Compliance-Events (Payload, Referenzen, Log-Ketten, Mismatches).';
