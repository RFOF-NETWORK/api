-- documents/actions/document_add_relation.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Fügt eine Beziehung zwischen zwei Dokumenten hinzu + Audit-Log

CREATE OR REPLACE FUNCTION action_document_add_relation(
    p_document_id      UUID,
    p_related_id       UUID,
    p_relation_type    TEXT,      -- z.B. 'REFERS_TO', 'SUPERSEDES', 'CHILD_OF'
    p_actor_id         UUID,
    p_metadata         JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_relation_id UUID := gen_random_uuid();
BEGIN
    -- Relation speichern
    INSERT INTO document_relations (
        relation_id,
        document_id,
        related_document_id,
        relation_type,
        metadata
    )
    VALUES (
        v_relation_id,
        p_document_id,
        p_related_id,
        p_relation_type,
        p_metadata
    )
    ON CONFLICT (document_id, related_document_id, relation_type)
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
        'ADD_RELATION',
        p_actor_id,
        jsonb_build_object(
            'related_document', p_related_id,
            'relation_type', p_relation_type
        ) || p_metadata
    );

    RETURN v_relation_id;
END;
$$;

COMMENT ON FUNCTION action_document_add_relation IS
'Fügt eine Beziehung zwischen zwei Dokumenten hinzu und erzeugt einen Audit-Log-Eintrag.';
