-- Testreport generieren
CREATE OR REPLACE FUNCTION test_report()
RETURNS SETOF test_cases AS $$
BEGIN
    RETURN QUERY SELECT * FROM test_cases ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql;
