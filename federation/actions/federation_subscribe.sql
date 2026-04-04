-- federation_subscribe.sql
-- Action: Ein Föderationsknoten abonniert einen anderen Knoten

CREATE TABLE IF NOT EXISTS federation_subscription (
    subscription_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id   UUID NOT NULL,
    target_id       UUID NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION federation_subscribe(
    p_subscriber_id UUID,
    p_target_id     UUID
)
RETURNS JSONB
LANGUAGE sql
AS $$
    INSERT INTO federation_subscription (subscriber_id, target_id)
    VALUES (p_subscriber_id, p_target_id)
    RETURNING row_to_json(federation_subscription)::jsonb;
$$;
