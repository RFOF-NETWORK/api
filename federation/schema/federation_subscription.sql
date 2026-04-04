-- F70: Schema – Federation Subscription

CREATE TABLE IF NOT EXISTS federation_subscription (
    subscription_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    federation_id UUID NOT NULL,
    subscriber_name TEXT NOT NULL,
    event_type TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
