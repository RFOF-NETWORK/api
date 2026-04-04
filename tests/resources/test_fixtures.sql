-- Fixtures für Tests
CREATE TABLE IF NOT EXISTS test_fixtures (
    fixture_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);
