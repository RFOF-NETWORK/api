-- F74: Schema – Federation Audit Log

CREATE TABLE IF NOT EXISTS federation_audit (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID,
    action TEXT NOT NULL,
    details JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
