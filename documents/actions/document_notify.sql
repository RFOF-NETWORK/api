-- documents/actions/document_notify.sql
-- Modul: DOCUMENTS – ACTIONS
-- Zweck: Erzeugt eine Benachrichtigung zu einem Dokument + Audit-Log

CREATE OR REPLACE FUNCTION action_document_notify(
    p_document_id UUID,
    p_recipient_id UUID,
    p_event_type TEXT,      -- z.B. 'UPDATED', 'APPROVED', 'EXPIRED'
    p_actor_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_notification_id UUID := gen_random_uuid();
BEGIN
    -- Notification erzeugen
    INSERT INTO document_notifications (
        notification_id,
        document_id,
        recipient_id,
        event_type
    )
    VALUES (
        v_notification_id,
        p_document_id,
        p_recipient_id,
        p_event_type
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
        'NOTIFY',
        p_actor_id,
        jsonb_build_object(
            'recipient', p_recipient_id,
            'event_type', p_event_type
        )
    );

    RETURN v_notification_id;
END;
$$;

COMMENT ON FUNCTION action_document_notify IS
'Erzeugt eine Dokument-Benachrichtigung und schreibt einen Audit-Log-Eintrag.';
