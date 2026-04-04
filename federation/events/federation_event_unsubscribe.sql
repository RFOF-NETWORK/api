-- F52: Unsubscribe from Federation Events

CREATE OR REPLACE FUNCTION federation_event_unsubscribe(
    p_subscriber_name TEXT,
    p_event_type TEXT
)
RETURNS INT
LANGUAGE sql
AS $$
    DELETE FROM federation_event_subscription
    WHERE subscriber_name = p_subscriber_name
      AND event_type = p_event_type
    RETURNING 1;
$$;
