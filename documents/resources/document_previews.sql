-- documents/resources/document_previews.sql
-- Modul: DOCUMENTS
-- Zweck: Vorschaubilder / Thumbnails / Textauszüge für Dokumente

CREATE TABLE document_previews (
    preview_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id   UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    preview_type  TEXT NOT NULL,                         -- z.B. 'THUMBNAIL', 'TEXT_SNIPPET'
    preview_data  BYTEA NOT NULL,                        -- Binärdaten oder komprimierter Text
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE document_previews IS 'Vorschaudaten für Dokumente.';
COMMENT ON COLUMN document_previews.preview_type IS 'Art der Vorschau (Thumbnail, Textauszug etc.).';
COMMENT ON COLUMN document_previews.preview_data IS 'Binäre oder textuelle Vorschauinformationen.';
