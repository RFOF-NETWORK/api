-- F55: Event Status (processed, pending, failed)

CREATE TABLE IF NOT EXISTS federation_event_status (
    status_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL,
    status TEXT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION federation_event_set_status(
    p_event_id UUID,
    p_status TEXT
)
RETURNS VOID
LANGUAGE sql
AS $$
    INSERT INTO federation_event_status (event_id, status)
    VALUES (p_event_id, p_status);
$$;
