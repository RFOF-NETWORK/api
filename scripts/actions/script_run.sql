-- Script ausführen
CREATE OR REPLACE FUNCTION script_run(script_name TEXT)
RETURNS TEXT AS $$
DECLARE
    body TEXT;
BEGIN
    SELECT t.body INTO body
    FROM script_registry r
    JOIN script_templates t ON r.template_id = t.template_id
    WHERE r.name = script_name;

    RETURN 'executed: ' || script_name;
END;
$$ LANGUAGE plpgsql;
