-- F45: Dispatch Federation Events to subscribers

CREATE OR REPLACE FUNCTION federation_event_dispatch()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    evt RECORD;
BEGIN
    FOR evt IN
        SELECT * FROM federation_event ORDER BY created_at ASC
    LOOP
        -- Dispatch logic placeholder
        PERFORM pg_notify(evt.event_type, evt.payload::text);
    END LOOP;
END;
$$;
