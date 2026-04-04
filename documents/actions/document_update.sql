-- documents/actions/document_update.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Aktualisiert Titel/Beschreibung eines Dokuments + Audit-Log

CREATE OR REPLACE FUNCTION action_document_update(
    p_document_id   UUID,
    p_title         TEXT,
    p_description   TEXT,
    p_actor_id      UUID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE documents
    SET
        title        = p_title,
        description  = p_description,
        updated_at   = now()
    WHERE document_id = p_document_id;

    -- Audit-Eintrag
    INSERT INTO document_audit (
        document_id,
        action_type,
        actor_id,
        metadata
    )
    VALUES (
        p_document_id,
        'UPDATE',
        p_actor_id,
        jsonb_build_object(
            'title', p_title,
            'description', p_description
        )
    );
END;
$$;

COMMENT ON FUNCTION action_document_update IS
'Aktualisiert ein Dokument und erzeugt einen Audit-Log-Eintrag.';
