-- Event: Dokumentation aktualisiert
CREATE TABLE IF NOT EXISTS docs_updated (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
