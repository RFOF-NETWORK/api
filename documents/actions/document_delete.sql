-- documents/actions/document_delete.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Markiert ein Dokument als gelöscht + Audit-Log

CREATE OR REPLACE FUNCTION action_document_delete(
    p_document_id UUID,
    p_actor_id    UUID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Soft Delete (empfohlen für Auditierbarkeit)
    UPDATE documents
    SET
        deleted_at = now(),
        updated_at = now()
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
        'DELETE',
        p_actor_id,
        jsonb_build_object('soft_delete', true)
    );
END;
$$;

COMMENT ON FUNCTION action_document_delete IS
'Markiert ein Dokument als gelöscht und erzeugt einen Audit-Log-Eintrag.';
