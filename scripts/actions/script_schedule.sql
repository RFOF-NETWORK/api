-- Script planen
CREATE OR REPLACE FUNCTION script_schedule(script_name TEXT, cron TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE script_registry
    SET schedule = cron
    WHERE name = script_name;
END;
$$ LANGUAGE plpgsql;
