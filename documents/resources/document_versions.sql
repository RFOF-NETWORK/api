-- documents/resources/document_versions.sql
-- Modul: DOCUMENTS
-- Zweck: Versionierung von Dokumenten (jede Änderung erzeugt eine neue Version)

CREATE TABLE document_versions (
    version_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id       UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    version_number    INTEGER NOT NULL,
    content_hash      TEXT NOT NULL,                     -- SHA-256 Hash der Version
    storage_url       TEXT NOT NULL,                     -- Speicherort der Version
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    metadata          JSONB DEFAULT '{}'::jsonb          -- optionale Zusatzinfos
);

COMMENT ON TABLE document_versions IS 'Versionierungstabelle für Dokumente.';
COMMENT ON COLUMN document_versions.version_number IS 'Fortlaufende Versionsnummer (1, 2, 3, ...).';
COMMENT ON COLUMN document_versions.content_hash IS 'SHA-256 Hash der jeweiligen Version.';
COMMENT ON COLUMN document_versions.storage_url IS 'Speicherort der Version.';
COMMENT ON COLUMN document_versions.metadata IS 'Flexible Metadaten im JSON-Format.';

-- Automatische Versionierung erzwingen:
CREATE UNIQUE INDEX document_versions_unique_version
    ON document_versions(document_id, version_number);
