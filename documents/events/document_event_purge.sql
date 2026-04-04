-- documents/events/document_event_purge.sql
-- Modul: DOCUMENTS – EVENTS
-- Zweck: Löscht oder archiviert alte Events basierend auf Status und Alter

CREATE OR REPLACE FUNCTION event_document_purge(
    p_status_filter TEXT[] DEFAULT ARRAY['SUCCESS', 'DEADLETTER'],
    p_older_than INTERVAL DEFAULT '30 days'
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted INTEGER;
BEGIN
    DELETE FROM document_events
    WHERE status = ANY(p_status_filter)
      AND created_at < now() - p_older_than
    RETURNING 1 INTO v_deleted;

    RETURN COALESCE(v_deleted, 0);
END;
$$;

COMMENT ON FUNCTION event_document_purge IS
'Löscht alte Dokument-Events basierend auf Status und Alter.';
