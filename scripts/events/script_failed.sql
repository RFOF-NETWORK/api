-- Event: Script fehlgeschlagen
CREATE TABLE IF NOT EXISTS script_failed (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    script_name TEXT NOT NULL,
    error TEXT NOT NULL,
    failed_at TIMESTAMPTZ DEFAULT now()
);
