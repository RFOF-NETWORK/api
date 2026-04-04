-- Event: Script beendet
CREATE TABLE IF NOT EXISTS script_finished (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    script_name TEXT NOT NULL,
    finished_at TIMESTAMPTZ DEFAULT now()
);
