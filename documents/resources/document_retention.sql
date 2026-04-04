-- documents/resources/document_retention.sql
-- Modul: DOCUMENTS
-- Zweck: Aufbewahrungsrichtlinien für Dokumente (Retention, Löschfristen, Legal Hold)

CREATE TABLE document_retention (
    retention_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id      UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    retention_policy TEXT NOT NULL,                         -- z.B. '7_YEARS', 'INDEFINITE', 'LEGAL_HOLD'
    expires_at       TIMESTAMPTZ,                           -- Zeitpunkt der geplanten Löschung (falls zutreffend)
    legal_hold       BOOLEAN NOT NULL DEFAULT false,        -- verhindert Löschung
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    metadata         JSONB DEFAULT '{}'::jsonb              -- optionale Zusatzinfos
);

COMMENT ON TABLE document_retention IS 'Aufbewahrungsrichtlinien für Dokumente.';
COMMENT ON COLUMN document_retention.retention_policy IS 'Definierte Aufbewahrungsregel.';
COMMENT ON COLUMN document_retention.expires_at IS 'Geplanter Löschzeitpunkt.';
COMMENT ON COLUMN document_retention.legal_hold IS 'Verhindert Löschung bei rechtlicher Sperre.';
