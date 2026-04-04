-- F43: Federation Flags (Feature Flags)

CREATE TABLE IF NOT EXISTS federation_flag (
    flag_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flag_key TEXT NOT NULL UNIQUE,
    flag_enabled BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_flag (flag_key, flag_enabled)
VALUES
    ('enable_replay_v2', false),
    ('enable_trust_auto_adjust', true),
    ('enable_cross_region_sync', false)
ON CONFLICT DO NOTHING;
