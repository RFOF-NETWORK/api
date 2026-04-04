-- F32: Statische Validierungsregeln für Federation

CREATE TABLE IF NOT EXISTS federation_validation_rule (
    rule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name TEXT NOT NULL UNIQUE,
    rule_definition JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_validation_rule (rule_name, rule_definition)
VALUES
    ('trust_range', '{"min":0,"max":100}'),
    ('domain_required', '{"required":true}'),
    ('node_type_required', '{"required":true}')
ON CONFLICT DO NOTHING;
