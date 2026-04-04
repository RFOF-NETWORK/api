-- documents/actions/document_set_workflow_state.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Setzt den Workflow-Status eines Dokuments + Audit-Log

CREATE OR REPLACE FUNCTION action_document_set_workflow_state(
    p_document_id    UUID,
    p_workflow_state TEXT,     -- z.B. 'DRAFT', 'IN_REVIEW', 'APPROVED', 'PUBLISHED'
    p_actor_id       UUID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Workflow-Eintrag aktualisieren oder anlegen
    INSERT INTO document_workflows (
        workflow_id,
        document_id,
        workflow_state,
        assigned_to
    )
    VALUES (
        gen_random_uuid(),
        p_document_id,
        p_workflow_state,
        p_actor_id
    )
    ON CONFLICT (document_id)
    DO UPDATE SET
        workflow_state = EXCLUDED.workflow_state,
        assigned_to    = EXCLUDED.assigned_to,
        updated_at     = now();

    -- Audit-Eintrag
    INSERT INTO document_audit (
        document_id,
        action_type,
        actor_id,
        metadata
    )
    VALUES (
        p_document_id,
        'SET_WORKFLOW_STATE',
        p_actor_id,
        jsonb_build_object(
            'workflow_state', p_workflow_state
        )
    );
END;
$$;

COMMENT ON FUNCTION action_document_set_workflow_state IS
'Setzt den Workflow-Status eines Dokuments und erzeugt einen Audit-Log-Eintrag.';
