-- F35: Security Policies für Federation

CREATE TABLE IF NOT EXISTS federation_security_policy (
    policy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_key TEXT NOT NULL UNIQUE,
    policy_value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_security_policy (policy_key, policy_value)
VALUES
    ('allow_external_nodes', '{"enabled":false}'),
    ('require_tls', '{"enabled":true}'),
    ('max_failed_attempts', '{"value":5}')
ON CONFLICT DO NOTHING;
