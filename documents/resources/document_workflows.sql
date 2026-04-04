-- documents/resources/document_workflows.sql
-- Modul: DOCUMENTS
-- Zweck: Workflow-Status und Prozessketten für Dokumente (Review, Approval, Publishing)

CREATE TABLE document_workflows (
    workflow_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id     UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    workflow_state  TEXT NOT NULL,                         -- z.B. 'DRAFT', 'IN_REVIEW', 'APPROVED', 'PUBLISHED'
    assigned_to     UUID,                                  -- Benutzer oder System, das den Schritt bearbeitet
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    metadata        JSONB DEFAULT '{}'::jsonb              -- optionale Zusatzinfos
);

COMMENT ON TABLE document_workflows IS 'Workflow-Status und Prozessketten für Dokumente.';
COMMENT ON COLUMN document_workflows.workflow_state IS 'Aktueller Workflow-Zustand.';
COMMENT ON COLUMN document_workflows.assigned_to IS 'Zuständiger Benutzer oder System.';
