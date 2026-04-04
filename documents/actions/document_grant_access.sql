-- documents/actions/document_grant_access.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Vergibt einem Benutzer/System Zugriff auf ein Dokument + Audit-Log

CREATE OR REPLACE FUNCTION action_document_grant_access(
    p_document_id UUID,
    p_grantee_id  UUID,
    p_access_type TEXT,      -- z.B. 'READ', 'WRITE', 'ADMIN'
    p_actor_id    UUID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO document_access (
        access_id,
        document_id,
        grantee_id,
        access_type
    )
    VALUES (
        gen_random_uuid(),
        p_document_id,
        p_grantee_id,
        p_access_type
    )
    ON CONFLICT (document_id, grantee_id, access_type)
    DO NOTHING;

    -- Audit-Eintrag
    INSERT INTO document_audit (
        document_id,
        action_type,
        actor_id,
        metadata
    )
    VALUES (
        p_document_id,
        'GRANT_ACCESS',
        p_actor_id,
        jsonb_build_object(
            'grantee', p_grantee_id,
            'access_type', p_access_type
        )
    );
END;
$$;

COMMENT ON FUNCTION action_document_grant_access IS
'Vergibt einem Benutzer/System Zugriff auf ein Dokument und erzeugt einen Audit-Log-Eintrag.';
