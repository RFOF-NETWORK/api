-- documents/resources/document_signatures.sql
-- Modul: DOCUMENTS
-- Zweck: Digitale Signaturen für Dokumente (Benutzer- oder Systemsignaturen)

CREATE TABLE document_signatures (
    signature_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id    UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    signer_id      UUID NOT NULL,                         -- Benutzer oder System
    signature_algo TEXT NOT NULL,                         -- z.B. 'ED25519', 'RSA2048'
    signature      BYTEA NOT NULL,                        -- Signaturdaten
    signed_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    metadata       JSONB DEFAULT '{}'::jsonb              -- optionale Zusatzinfos
);

COMMENT ON TABLE document_signatures IS 'Digitale Signaturen für Dokumente.';
COMMENT ON COLUMN document_signatures.signer_id IS 'Benutzer oder System, das signiert hat.';
COMMENT ON COLUMN document_signatures.signature_algo IS 'Verwendeter Signaturalgorithmus.';
COMMENT ON COLUMN document_signatures.signature IS 'Digitale Signaturdaten.';
