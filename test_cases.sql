-- Testfälle
CREATE TABLE IF NOT EXISTS test_cases (
    case_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    input JSONB NOT NULL,
    expected JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);
