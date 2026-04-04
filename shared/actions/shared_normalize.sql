-- Normalisierung
CREATE OR REPLACE FUNCTION shared_normalize(v TEXT) RETURNS TEXT AS $$
BEGIN
    RETURN lower(trim(v));
END;
$$ LANGUAGE plpgsql;
