-- F89: Schema – Federation Validation Rules

CREATE TABLE IF NOT EXISTS federation_validation_rule (
    rule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name TEXT NOT NULL UNIQUE,
    rule_definition JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
