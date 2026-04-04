-- documents/actions/document_create.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Aktion zum Erstellen eines neuen Dokuments (Business-Logik-Ebene)

CREATE OR REPLACE FUNCTION action_document_create(
    p_title        TEXT,
    p_description  TEXT,
    p_created_by   UUID
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_document_id UUID := gen_random_uuid();
BEGIN
    INSERT INTO documents (
        document_id,
        title,
        description,
        created_by
    )
    VALUES (
        v_document_id,
        p_title,
        p_description,
        p_created_by
    );

    -- Audit-Eintrag
    INSERT INTO document_audit (
        document_id,
        action_type,
        actor_id,
        metadata
    )
    VALUES (
        v_document_id,
        'CREATE',
        p_created_by,
        jsonb_build_object('title', p_title)
    );

    RETURN v_document_id;
END;
$$;

COMMENT ON FUNCTION action_document_create IS
'Erstellt ein neues Dokument und erzeugt einen Audit-Log-Eintrag.';
