-- documents/resources/document_access.sql
-- Modul: DOCUMENTS
-- Zweck: Zugriffskontrolle für Dokumente (ACL)

CREATE TABLE document_access (
    access_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id   UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    grantee_id    UUID NOT NULL,                         -- Benutzer oder Systementität
    access_level  TEXT NOT NULL,                         -- z.B. 'READ', 'WRITE', 'OWNER'
    granted_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE document_access IS 'Zugriffskontrollliste für Dokumente.';
COMMENT ON COLUMN document_access.grantee_id IS 'Benutzer oder Entität, die Zugriff erhält.';
COMMENT ON COLUMN document_access.access_level IS 'Zugriffsebene (READ, WRITE, OWNER).';
