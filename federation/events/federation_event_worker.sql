-- F58: Event Worker (verarbeitet Events aus der Queue)

CREATE OR REPLACE FUNCTION federation_event_worker(
    p_limit INT DEFAULT 50
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    q RECORD;
BEGIN
    FOR q IN
        SELECT * FROM federation_event_dequeue(p_limit)
    LOOP
        PERFORM federation_event_dispatch();
    END LOOP;
END;
$$;
