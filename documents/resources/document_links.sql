-- documents/resources/document_links.sql
-- Modul: DOCUMENTS
-- Zweck: Verknüpfung von Dokumenten mit beliebigen Entitäten (Accounts, Ledger, Identity, Compliance etc.)

CREATE TABLE document_links (
    link_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id        UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    linked_entity_type TEXT NOT NULL,                     -- z.B. 'ACCOUNT', 'USER', 'LEDGER_ENTRY'
    linked_entity_id   UUID NOT NULL,                     -- ID der verknüpften Entität
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE document_links IS 'Verknüpfungstabelle zwischen Dokumenten und beliebigen Systementitäten.';
COMMENT ON COLUMN document_links.linked_entity_type IS 'Typ der verknüpften Entität.';
COMMENT ON COLUMN document_links.linked_entity_id IS 'ID der verknüpften Entität.';
