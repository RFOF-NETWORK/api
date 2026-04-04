-- documents/actions/document_add_signature.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Fügt einem Dokument eine digitale Signatur hinzu + Audit-Log

CREATE OR REPLACE FUNCTION action_document_add_signature(
    p_document_id UUID,
    p_actor_id    UUID,
    p_signature   TEXT,      -- z.B. Base64, Hash, PKCS#7, etc.
    p_metadata    JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_signature_id UUID := gen_random_uuid();
BEGIN
    -- Signatur speichern
    INSERT INTO document_signatures (
        signature_id,
        document_id,
        actor_id,
        signature,
        metadata
    )
    VALUES (
        v_signature_id,
        p_document_id,
        p_actor_id,
        p_signature,
        p_metadata
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
        'ADD_SIGNATURE',
        p_actor_id,
        jsonb_build_object(
            'signature_id', v_signature_id
        )
        || p_metadata
    );

    RETURN v_signature_id;
END;
$$;

COMMENT ON FUNCTION action_document_add_signature IS
'Fügt einem Dokument eine digitale Signatur hinzu und erzeugt einen Audit-Log-Eintrag.';
