CREATE TABLE IF NOT EXISTS compliance_actions (
    action_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    compliance_id      UUID NOT NULL,
    action_type        TEXT NOT NULL,
    status             TEXT NOT NULL DEFAULT 'OPEN',
    assignee           TEXT,
    escalation_level   INTEGER DEFAULT 0,
    payload            JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS compliance_action_history (
    history_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    action_id          UUID NOT NULL,
    event_type         TEXT NOT NULL,
    payload            JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
