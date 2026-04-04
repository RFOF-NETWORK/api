-- documents/actions/document_set_retention.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Setzt die Aufbewahrungsrichtlinie eines Dokuments + Audit-Log

CREATE OR REPLACE FUNCTION action_document_set_retention(
    p_document_id     UUID,
    p_retention_until TIMESTAMPTZ,
    p_actor_id        UUID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retention-Eintrag aktualisieren oder anlegen
    INSERT INTO document_retention (
        retention_id,
        document_id,
        retention_until
    )
    VALUES (
        gen_random_uuid(),
        p_document_id,
        p_retention_until
    )
    ON CONFLICT (document_id)
    DO UPDATE SET
        retention_until = EXCLUDED.retention_until,
        updated_at      = now();

    -- Audit-Eintrag
    INSERT INTO document_audit (
        document_id,
        action_type,
        actor_id,
        metadata
    )
    VALUES (
        p_document_id,
        'SET_RETENTION',
        p_actor_id,
        jsonb_build_object(
            'retention_until', p_retention_until
        )
    );
END;
$$;

COMMENT ON FUNCTION action_document_set_retention IS
'Setzt die Aufbewahrungsrichtlinie eines Dokuments und erzeugt einen Audit-Log-Eintrag.';
