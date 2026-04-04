-- Generiert Dokumentation
CREATE OR REPLACE FUNCTION docs_generate()
RETURNS TEXT AS $$
BEGIN
    RETURN 'documentation generated';
END;
$$ LANGUAGE plpgsql;
