-- documents/events/document_event_subscribe.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Registrierung von Event-Handlern für bestimmte Event-Typen

CREATE OR REPLACE FUNCTION event_document_subscribe(
    p_event_type TEXT,
    p_handler    TEXT,
    p_metadata   JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO document_event_subscriptions (
        subscription_id,
        event_type,
        handler,
        metadata,
        created_at
    )
    VALUES (
        gen_random_uuid(),
        p_event_type,
        p_handler,
        p_metadata,
        now()
    );
END;
$$;

COMMENT ON FUNCTION event_document_subscribe IS
'Registriert einen Handler für einen bestimmten Dokument-Event-Typ.';
