-- documents/resources/document_audit.sql
-- Modul: DOCUMENTS
-- Zweck: Audit-Log für Dokumentaktionen (Erstellung, Änderung, Zugriff, Löschung)

CREATE TABLE document_audit (
    audit_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id   UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    action_type   TEXT NOT NULL,                         -- z.B. 'CREATE', 'UPDATE', 'ACCESS', 'DELETE'
    actor_id      UUID NOT NULL,                         -- Benutzer oder System
    action_time   TIMESTAMPTZ NOT NULL DEFAULT now(),
    metadata      JSONB DEFAULT '{}'::jsonb              -- zusätzliche Audit-Informationen
);

COMMENT ON TABLE document_audit IS 'Audit-Log für alle Dokumentaktionen.';
COMMENT ON COLUMN document_audit.action_type IS 'Art der Aktion (CREATE, UPDATE, ACCESS, DELETE).';
COMMENT ON COLUMN document_audit.actor_id IS 'Benutzer oder System, das die Aktion ausgeführt hat.';
COMMENT ON COLUMN document_audit.metadata IS 'Zusätzliche Audit-Informationen.';
