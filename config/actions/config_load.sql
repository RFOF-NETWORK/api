-- Lädt einen Config-Wert
CREATE OR REPLACE FUNCTION config_load(k TEXT)
RETURNS TEXT AS $$
DECLARE v TEXT;
BEGIN
    SELECT value INTO v FROM config_env WHERE key = k;
    RETURN v;
END;
$$ LANGUAGE plpgsql;
