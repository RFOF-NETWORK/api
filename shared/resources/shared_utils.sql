-- Utility-Funktionen
CREATE OR REPLACE FUNCTION util_trim(v TEXT) RETURNS TEXT AS $$
BEGIN
    RETURN trim(v);
END;
$$ LANGUAGE plpgsql;
