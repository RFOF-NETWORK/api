-- documents/resources/document_relations.sql
-- Modul: DOCUMENTS
-- Zweck: Relationen zwischen Dokumenten (z.B. Versionierungsbäume, Abhängigkeiten, Referenzen)

CREATE TABLE document_relations (
    relation_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_document  UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    child_document   UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    relation_type    TEXT NOT NULL,                         -- z.B. 'DERIVED_FROM', 'REFERENCES', 'DEPENDS_ON'
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    metadata         JSONB DEFAULT '{}'::jsonb              -- optionale Zusatzinfos
);

COMMENT ON TABLE document_relations IS 'Beziehungen zwischen Dokumenten.';
COMMENT ON COLUMN document_relations.parent_document IS 'Übergeordnetes Dokument.';
COMMENT ON COLUMN document_relations.child_document IS 'Abgeleitetes oder referenziertes Dokument.';
COMMENT ON COLUMN document_relations.relation_type IS 'Art der Beziehung.';
