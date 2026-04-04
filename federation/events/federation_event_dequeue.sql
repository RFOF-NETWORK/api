-- F57: Dequeue Federation Events (FIFO)

CREATE OR REPLACE FUNCTION federation_event_dequeue(
    p_limit INT DEFAULT 50
)
RETURNS SETOF federation_event_queue
LANGUAGE sql
AS $$
    DELETE FROM federation_event_queue
    WHERE queue_id IN (
        SELECT queue_id
        FROM federation_event_queue
        ORDER BY queued_at ASC
        LIMIT p_limit
    )
    RETURNING *;
$$;
