-- F51: Subscribe to Federation Events

CREATE TABLE IF NOT EXISTS federation_event_subscription (
    subscription_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_name TEXT NOT NULL,
    event_type TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION federation_event_subscribe(
    p_subscriber_name TEXT,
    p_event_type TEXT
)
RETURNS JSONB
LANGUAGE sql
AS $$
    INSERT INTO federation_event_subscription (subscriber_name, event_type)
    VALUES (p_subscriber_name, p_event_type)
    RETURNING row_to_json(federation_event_subscription)::jsonb;
$$;
