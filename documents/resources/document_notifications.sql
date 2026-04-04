-- documents/resources/document_notifications.sql
-- Modul: DOCUMENTS
-- Zweck: Benachrichtigungen zu Dokumentereignissen (Review, Freigabe, Änderungen, Ablauf)

CREATE TABLE document_notifications (
    notification_id  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id      UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    recipient_id     UUID NOT NULL,                         -- Benutzer oder System
    event_type       TEXT NOT NULL,                         -- z.B. 'UPDATED', 'APPROVED', 'EXPIRED'
    sent_at          TIMESTAMPTZ,                           -- Zeitpunkt der tatsächlichen Zustellung
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    metadata         JSONB DEFAULT '{}'::jsonb              -- optionale Zusatzinfos
);

COMMENT ON TABLE document_notifications IS 'Benachrichtigungen zu Dokumentereignissen.';
COMMENT ON COLUMN document_notifications.recipient_id IS 'Empfänger der Benachrichtigung.';
COMMENT ON COLUMN document_notifications.event_type IS 'Auslösendes Ereignis.';
