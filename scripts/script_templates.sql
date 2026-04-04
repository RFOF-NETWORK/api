-- Vorlagen für Scripts
CREATE TABLE IF NOT EXISTS script_templates (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);
