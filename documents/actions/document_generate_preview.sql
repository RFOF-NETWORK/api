-- documents/actions/document_generate_preview.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Erzeugt eine Vorschau (Preview) für ein Dokument + Audit-Log

CREATE OR REPLACE FUNCTION action_document_generate_preview(
    p_document_id UUID,
    p_preview_data BYTEA,     -- z.B. PNG, JPEG, PDF-Thumbnail, etc.
    p_actor_id    UUID,
    p_metadata    JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_preview_id UUID := gen_random_uuid();
BEGIN
    -- Preview speichern
    INSERT INTO document_previews (
        preview_id,
        document_id,
        preview_data,
        metadata
    )
    VALUES (
        v_preview_id,
        p_document_id,
        p_preview_data,
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
        'GENERATE_PREVIEW',
        p_actor_id,
        jsonb_build_object(
            'preview_id', v_preview_id
        )
        || p_metadata
    );

    RETURN v_preview_id;
END;
$$;

COMMENT ON FUNCTION action_document_generate_preview IS
'Erzeugt eine Vorschau für ein Dokument und schreibt einen Audit-Log-Eintrag.';
