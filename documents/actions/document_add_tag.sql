-- documents/actions/document_add_tag.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Fügt einem Dokument ein Tag hinzu + Audit-Log

CREATE OR REPLACE FUNCTION action_document_add_tag(
    p_document_id UUID,
    p_tag         TEXT,
    p_actor_id    UUID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_tag_id UUID;
BEGIN
    -- Tag anlegen, falls es nicht existiert
    SELECT tag_id INTO v_tag_id
    FROM document_tags
    WHERE tag = p_tag;

    IF v_tag_id IS NULL THEN
        v_tag_id := gen_random_uuid();

        INSERT INTO document_tags (
            tag_id,
            tag
        )
        VALUES (
            v_tag_id,
            p_tag
        );
    END IF;

    -- Verknüpfung Dokument <-> Tag
    INSERT INTO document_links (
        link_id,
        document_id,
        tag_id
    )
    VALUES (
        gen_random_uuid(),
        p_document_id,
        v_tag_id
    )
    ON CONFLICT DO NOTHING;

    -- Audit-Eintrag
    INSERT INTO document_audit (
        document_id,
        action_type,
        actor_id,
        metadata
    )
    VALUES (
        p_document_id,
        'ADD_TAG',
        p_actor_id,
        jsonb_build_object('tag', p_tag)
    );
END;
$$;

COMMENT ON FUNCTION action_document_add_tag IS
'Fügt einem Dokument ein Tag hinzu und erzeugt einen Audit-Log-Eintrag.';
