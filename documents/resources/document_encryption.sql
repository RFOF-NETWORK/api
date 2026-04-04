-- documents/resources/document_encryption.sql
-- Modul: DOCUMENTS
-- Zweck: Verschlüsselungsinformationen für Dokumente (Schlüssel, Verfahren, Rotation)

CREATE TABLE document_encryption (
    encryption_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id      UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    encryption_algo  TEXT NOT NULL,                         -- z.B. 'AES256-GCM', 'ChaCha20-Poly1305'
    key_reference    TEXT NOT NULL,                         -- Verweis auf KMS/Key-ID
    encrypted_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    metadata         JSONB DEFAULT '{}'::jsonb              -- optionale Zusatzinfos
);

COMMENT ON TABLE document_encryption IS 'Verschlüsselungsinformationen für Dokumente.';
COMMENT ON COLUMN document_encryption.encryption_algo IS 'Verwendetes Verschlüsselungsverfahren.';
COMMENT ON COLUMN document_encryption.key_reference IS 'Referenz auf Schlüsselmaterial (KMS/Key-ID).';
