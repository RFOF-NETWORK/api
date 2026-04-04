-- api/compliance/actions/compliance_resolve.sql
-- Modul: COMPLIANCE
-- Zweck: Schließt einen Compliance-Fall ab (RESOLVED oder FAILED)

CREATE OR REPLACE FUNCTION compliance_resolve(
    p_compliance_id   UUID,
    p_resolution      TEXT,                 -- RESOLVED oder FAILED
    p_notes           TEXT DEFAULT NULL,
    p_metadata_patch  JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_old RECORD;
    v_new_metadata JSONB;
    v_final_status TEXT;
BEGIN
    -- 1. Datensatz laden
    SELECT *
    INTO v_old
    FROM compliance
    WHERE compliance_id = p_compliance_id;

    IF v_old IS NULL THEN
        RETURN jsonb_build_object(
            'error', 'COMPLIANCE_NOT_FOUND',
            'compliance_id', p_compliance_id
        );
    END IF;

    -- 2. Finalen Status bestimmen
    v_final_status := CASE p_resolution
        WHEN 'RESOLVED' THEN 'ACTIVE'
        WHEN 'FAILED'   THEN 'BLOCKED'
        ELSE 'REVIEW'
    END;

    -- 3. Metadaten mergen
    v_new_metadata := v_old.metadata || jsonb_build_object(
        'resolution', p_resolution,
        'notes', p_notes,
        'resolved_at', now()
    ) || p_metadata_patch;

    -- 4. Update durchführen
    UPDATE compliance
    SET
        compliance_status = v_final_status,
        metadata = v_new_metadata,
        updated_at = now()
    WHERE compliance_id = p_compliance_id;

    -- 5. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'compliance_id', p_compliance_id,
        'final_status', v_final_status,
        'resolution', p_resolution,
        'metadata', v_new_metadata,
        'resolved_at', now()
    );
END;
$$;

COMMENT ON FUNCTION compliance_resolve IS
'Schließt einen Compliance-Fall ab und setzt finalen Status (RESOLVED/FAILED).';
