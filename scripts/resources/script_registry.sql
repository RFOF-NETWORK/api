-- Registry aller Scripts
CREATE TABLE IF NOT EXISTS script_registry (
    script_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    template_id UUID REFERENCES script_templates(template_id),
    schedule TEXT,
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT now()
);
