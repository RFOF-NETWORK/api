-- Event-Log-Reader
CREATE OR REPLACE FUNCTION shared_event_read() RETURNS SETOF shared_event_log AS $$
BEGIN
    RETURN QUERY SELECT * FROM shared_event_log ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql;
