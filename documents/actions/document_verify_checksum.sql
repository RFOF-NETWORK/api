-- documents/actions/document_verify_checksum.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Prüft die Checksumme eines Dokuments + Audit-Log

CREATE OR REPLACE FUNCTION action_document_verify_checksum(
    p_document_id UUID,
    p_checksum    TEXT,
    p_actor_id    UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Prüfen, ob die Checksumme existiert
    SELECT EXISTS (
        SELECT 1
        FROM document_checksums
        WHERE document_id = p_document_id
          AND checksum = p_checksum
    )
    INTO v_exists;

    -- Audit-Eintrag
    INSERT INTO document_audit (
        document_id,
        action_type,
        actor_id,
        metadata
    )
    VALUES (
        p_document_id,
        'VERIFY_CHECKSUM',
        p_actor_id,
        jsonb_build_object(
            'checksum', p_checksum,
            'valid', v_exists
        )
    );

    RETURN v_exists;
END;
$$;

COMMENT ON FUNCTION action_document_verify_checksum IS
'Prüft die Checksumme eines Dokuments und erzeugt einen Audit-Log-Eintrag.';
