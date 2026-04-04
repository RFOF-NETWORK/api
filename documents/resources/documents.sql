-- documents/resources/documents.sql
-- Modul: DOCUMENTS
-- Zweck: Zentrale Dokumententabelle für alle Module (Identity, Accounts, Ledger, Compliance, Federation)

CREATE TABLE documents (
    document_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id           UUID NOT NULL,                     -- Verweis auf identity.users
    document_type      TEXT NOT NULL,                     -- z.B. "KYC", "CONTRACT", "LEDGER_EXPORT"
    content_hash       TEXT NOT NULL,                     -- SHA-256 Hash des Inhalts
    storage_url        TEXT NOT NULL,                     -- Speicherort (S3, MinIO, IPFS, etc.)
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    metadata           JSONB DEFAULT '{}'::jsonb          -- flexible Zusatzinfos
);

COMMENT ON TABLE documents IS 'Zentrale Dokumententabelle für alle Module.';
COMMENT ON COLUMN documents.owner_id IS 'Referenz auf identity.users.user_id.';
COMMENT ON COLUMN documents.document_type IS 'Typ des Dokuments (KYC, Vertrag, Ledger-Export etc.).';
COMMENT ON COLUMN documents.content_hash IS 'SHA-256 Hash zur Integritätsprüfung.';
COMMENT ON COLUMN documents.storage_url IS 'Speicherort des Dokuments.';
COMMENT ON COLUMN documents.metadata IS 'Flexible Metadaten im JSON-Format.';
