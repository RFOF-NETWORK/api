-- Assertion
CREATE OR REPLACE FUNCTION test_assert(expected JSONB, actual JSONB)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN expected = actual;
END;
$$ LANGUAGE plpgsql;
