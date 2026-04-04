-- F86: Schema – Federation Audit Rules

CREATE TABLE IF NOT EXISTS federation_audit_rule (
    rule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_key TEXT NOT NULL UNIQUE,
    rule_definition JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
