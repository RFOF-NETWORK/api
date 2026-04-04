-- Dummy-Decrypt
CREATE OR REPLACE FUNCTION shared_decrypt(v TEXT) RETURNS TEXT AS $$
BEGIN
    RETURN replace(v, 'enc_', '');
END;
$$ LANGUAGE plpgsql;
