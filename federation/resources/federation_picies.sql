-- F20: Statische Federation-Policies

CREATE TABLE IF NOT EXISTS federation_policy (
    policy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_name TEXT NOT NULL UNIQUE,
    policy_data JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_policy (policy_name, policy_data)
VALUES
    ('default_trust', '{"min":50,"max":100}'),
    ('subscription_limits', '{"max_subscriptions":1000}')
ON CONFLICT DO NOTHING;
