-- Event: Test gestartet
CREATE TABLE IF NOT EXISTS test_started (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_name TEXT NOT NULL,
    started_at TIMESTAMPTZ DEFAULT now()
);
