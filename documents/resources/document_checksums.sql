-- documents/resources/document_checksums.sql
-- Modul: DOCUMENTS
-- Zweck: Zusätzliche Integritätsprüfungen für Dokumente (Mehrfach-Hashes, externe Prüfsummen)

CREATE TABLE document_checksums (
    checksum_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id    UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    algorithm      TEXT NOT NULL,                         -- z.B. 'SHA256', 'SHA512', 'BLAKE3'
    checksum       TEXT NOT NULL,                         -- Ergebnis der Prüfsumme
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE document_checksums IS 'Zusätzliche Prüfsummen für Dokumente.';
COMMENT ON COLUMN document_checksums.algorithm IS 'Verwendeter Hash-Algorithmus.';
COMMENT ON COLUMN document_checksums.checksum IS 'Ergebnis der Prüfsumme.';
