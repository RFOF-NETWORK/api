-- F48: Deadletter Queue für fehlerhafte Events

CREATE TABLE IF NOT EXISTS federation_event_deadletter (
    dead_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    original_event JSONB NOT NULL,
    error_message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION federation_event_deadletter(
    p_event JSONB,
    p_error TEXT
)
RETURNS VOID
LANGUAGE sql
AS $$
    INSERT INTO federation_event_deadletter (original_event, error_message)
    VALUES (p_event, p_error);
$$;
