-- documents/actions/document_create_version.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Erzeugt eine neue Version eines Dokuments + Checksum + Audit-Log

CREATE OR REPLACE FUNCTION action_document_create_version(
    p_document_id UUID,
    p_checksum    TEXT,
    p_actor_id    UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_next_version INTEGER;
BEGIN
    -- Nächste Versionsnummer bestimmen
    SELECT COALESCE(MAX(version_number), 0) + 1
    INTO v_next_version
    FROM document_versions
    WHERE document_id = p_document_id;

    -- Version anlegen
    INSERT INTO document_versions (
        version_id,
        document_id,
        version_number,
        created_by,
        checksum
    )
    VALUES (
        gen_random_uuid(),
        p_document_id,
        v_next_version,
        p_actor_id,
        p_checksum
    );

    -- Checksum-Tracking
    INSERT INTO document_checksums (
        checksum_id,
        document_id,
        checksum
    )
    VALUES (
        gen_random_uuid(),
        p_document_id,
        p_checksum
    );

    -- Audit-Eintrag
    INSERT INTO document_audit (
        document_id,
        action_type,
        actor_id,
        metadata
    )
    VALUES (
        p_document_id,
        'CREATE_VERSION',
        p_actor_id,
        jsonb_build_object(
            'version', v_next_version,
            'checksum', p_checksum
        )
    );

    RETURN v_next_version;
END;
$$;

COMMENT ON FUNCTION action_document_create_version IS
'Erzeugt eine neue Dokumentversion, speichert die Checksumme und erzeugt einen Audit-Log-Eintrag.';
