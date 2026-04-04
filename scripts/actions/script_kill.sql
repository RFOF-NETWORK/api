-- Script stoppen
CREATE OR REPLACE FUNCTION script_kill(script_name TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE script_registry
    SET enabled = FALSE
    WHERE name = script_name;
END;
$$ LANGUAGE plpgsql;
