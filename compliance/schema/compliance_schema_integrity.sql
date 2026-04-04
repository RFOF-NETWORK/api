CREATE OR REPLACE FUNCTION compliance_schema_integrity()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_missing_tables JSONB := '[]'::jsonb;
    v_missing_columns JSONB := '[]'::jsonb;
BEGIN
    -- Beispielhafte Checks (erweiterbar)

    -- Check: compliance table exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_name = 'compliance'
    ) THEN
        v_missing_tables := v_missing_tables || '"compliance"'::jsonb;
    END IF;

    -- Check: document_events table exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_name = 'document_events'
    ) THEN
        v_missing_tables := v_missing_tables || '"document_events"'::jsonb;
    END IF;

    RETURN jsonb_build_object(
        'missing_tables', v_missing_tables,
        'missing_columns', v_missing_columns,
        'checked_at', now()
    );
END;
$$;
