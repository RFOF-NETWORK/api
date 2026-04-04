-- Setzt Config auf Default zurück
CREATE OR REPLACE FUNCTION config_reset()
RETURNS VOID AS $$
BEGIN
    DELETE FROM config_env;
END;
$$ LANGUAGE plpgsql;
