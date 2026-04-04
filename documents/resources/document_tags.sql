-- documents/resources/document_tags.sql
-- Modul: DOCUMENTS
-- Zweck: Tagging-System für Dokumente (Schlagwörter, Klassifikation, Suche)

CREATE TABLE document_tags (
    tag_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id  UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    tag          TEXT NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE document_tags IS 'Tagging-Tabelle für Dokumente.';
COMMENT ON COLUMN document_tags.tag IS 'Schlagwort zur Klassifikation und Suche.';
