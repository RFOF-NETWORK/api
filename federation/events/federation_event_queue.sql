-- F56: Federation Event Queue (interne Warteschlange)

CREATE TABLE IF NOT EXISTS federation_event_queue (
    queue_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL,
    queued_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION federation_event_enqueue(
    p_event_id UUID
)
RETURNS VOID
LANGUAGE sql
AS $$
    INSERT INTO federation_event_queue (event_id)
    VALUES (p_event_id);
$$;
