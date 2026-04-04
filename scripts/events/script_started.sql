-- Event: Script gestartet
CREATE TABLE IF NOT EXISTS script_started (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    script_name TEXT NOT NULL,
    started_at TIMESTAMPTZ DEFAULT now()
);
