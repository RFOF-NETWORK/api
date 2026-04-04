-- Dummy-Encrypt
CREATE OR REPLACE FUNCTION shared_encrypt(v TEXT) RETURNS TEXT AS $$
BEGIN
    RETURN 'enc_' || v;
END;
$$ LANGUAGE plpgsql;
