-- documents/events/document_event_unsubscribe.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Entfernt einen registrierten Event-Handler für einen Event-Typ

CREATE OR REPLACE FUNCTION event_document_unsubscribe(
    p_event_type TEXT,
    p_handler    TEXT
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted INTEGER;
BEGIN
    DELETE FROM document_event_subscriptions
    WHERE event_type = p_event_type
      AND handler = p_handler
    RETURNING 1 INTO v_deleted;

    RETURN COALESCE(v_deleted, 0);
END;
$$;

COMMENT ON FUNCTION event_document_unsubscribe IS
'Entfernt einen registrierten Handler für einen bestimmten Dokument-Event-Typ.';
