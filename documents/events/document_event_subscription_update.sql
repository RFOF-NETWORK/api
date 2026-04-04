-- documents/events/document_event_subscription_update.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Aktualisiert eine bestehende Event-Subscription

CREATE OR REPLACE FUNCTION event_document_subscription_update(
    p_event_type TEXT,
    p_handler    TEXT,
    p_new_handler TEXT DEFAULT NULL,
    p_metadata   JSONB DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_old RECORD;
    v_updated INTEGER := 0;
BEGIN
    -- 1. Alte Subscription laden
    SELECT *
    INTO v_old
    FROM document_event_subscriptions
    WHERE event_type = p_event_type
      AND handler = p_handler;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'status', 'NOT_FOUND',
            'event_type', p_event_type,
            'handler', p_handler
        );
    END IF;

    -- 2. Subscription aktualisieren
    UPDATE document_event_subscriptions
    SET
        handler  = COALESCE(p_new_handler, handler),
        metadata = COALESCE(p_metadata, metadata),
        updated_at = now()
    WHERE event_type = p_event_type
      AND handler = p_handler
    RETURNING 1 INTO v_updated;

    -- 3. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'status', 'UPDATED',
        'event_type', p_event_type,
        'old_handler', p_handler,
        'new_handler', COALESCE(p_new_handler, p_handler),
        'metadata', COALESCE(p_metadata, v_old.metadata)
    );
END;
$$;

COMMENT ON FUNCTION event_document_subscription_update IS
'Aktualisiert Handler oder Metadata einer bestehenden Dokument-Event-Subscription.';
