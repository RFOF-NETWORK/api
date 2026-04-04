-- Führt einen Testfall aus
CREATE OR REPLACE FUNCTION test_run(case_name TEXT)
RETURNS JSONB AS $$
DECLARE
    tc RECORD;
BEGIN
    SELECT * INTO tc FROM test_cases WHERE name = case_name;

    RETURN jsonb_build_object(
        'case', tc.name,
        'status', 'executed',
        'expected', tc.expected
    );
END;
$$ LANGUAGE plpgsql;
