-- Setzt einen Config-Wert
CREATE OR REPLACE FUNCTION config_set(k TEXT, v TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO config_env (key, value, updated_at)
    VALUES (k, v, now())
    ON CONFLICT (key)
    DO UPDATE SET value = EXCLUDED.value, updated_at = now();
END;
$$ LANGUAGE plpgsql;
