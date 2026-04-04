-- Event: Test fehlgeschlagen
CREATE TABLE IF NOT EXISTS test_failed (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_name TEXT NOT NULL,
    error TEXT NOT NULL,
    failed_at TIMESTAMPTZ DEFAULT now()
);
