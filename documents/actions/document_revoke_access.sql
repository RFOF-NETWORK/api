-- documents/actions/document_revoke_access.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Entzieht einem Benutzer/System den Zugriff auf ein Dokument + Audit-Log

CREATE OR REPLACE FUNCTION action_document_revoke_access(
    p_document_id UUID,
    p_grantee_id  UUID,
    p_access_type TEXT,      -- z.B. 'READ', 'WRITE', 'ADMIN'
    p_actor_id    UUID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM document_access
    WHERE document_id = p_document_id
      AND grantee_id  = p_grantee_id
      AND access_type = p_access_type;

    -- Audit-Eintrag
    INSERT INTO document_audit (
        document_id,
        action_type,
        actor_id,
        metadata
    )
    VALUES (
        p_document_id,
        'REVOKE_ACCESS',
        p_actor_id,
        jsonb_build_object(
            'grantee', p_grantee_id,
            'access_type', p_access_type
        )
    );
END;
$$;

COMMENT ON FUNCTION action_document_revoke_access IS
'Entzieht einem Benutzer/System den Zugriff auf ein Dokument und erzeugt einen Audit-Log-Eintrag.';
