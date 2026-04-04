-- Hash-Funktion
CREATE OR REPLACE FUNCTION shared_hash(v TEXT) RETURNS TEXT AS $$
BEGIN
    RETURN encode(digest(v, 'sha256'), 'hex');
END;
$$ LANGUAGE plpgsql;
