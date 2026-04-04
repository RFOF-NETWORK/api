-- Event: Test bestanden
CREATE TABLE IF NOT EXISTS test_passed (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_name TEXT NOT NULL,
    passed_at TIMESTAMPTZ DEFAULT now()
);
