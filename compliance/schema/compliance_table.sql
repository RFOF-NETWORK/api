CREATE TABLE IF NOT EXISTS compliance (
    compliance_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_id          UUID NOT NULL,
    entity_type        TEXT NOT NULL,
    compliance_type    TEXT NOT NULL,
    compliance_status  TEXT NOT NULL,
    payload            JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
