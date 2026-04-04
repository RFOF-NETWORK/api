-- api/compliance/actions/compliance_update.sql
-- Modul: COMPLIANCE
-- Zweck: Aktualisiert einen bestehenden Compliance-Eintrag

CREATE OR REPLACE FUNCTION compliance_update(
    p_compliance_id   UUID,
    p_status          TEXT DEFAULT NULL,     -- ACTIVE, REVIEW, BLOCKED
    p_metadata_patch  JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_old RECORD;
    v_new_metadata JSONB;
BEGIN
    -- 1. Alten Datensatz laden
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

    -- 2. Metadaten mergen
    v_new_metadata := v_old.metadata || p_metadata_patch;

    -- 3. Update durchführen
    UPDATE compliance
    SET
        compliance_status = COALESCE(p_status, v_old.compliance_status),
        metadata = v_new_metadata,
        updated_at = now()
    WHERE compliance_id = p_compliance_id;

    -- 4. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'compliance_id', p_compliance_id,
        'status', COALESCE(p_status, v_old.compliance_status),
        'metadata', v_new_metadata,
        'updated_at', now()
    );
END;
$$;

COMMENT ON FUNCTION compliance_update IS
'Aktualisiert Status und Metadaten eines Compliance-Eintrags.';
