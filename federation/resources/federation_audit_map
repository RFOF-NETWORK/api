-- F34: Audit Map für Federation (welche Aktionen auditiert werden)

CREATE TABLE IF NOT EXISTS federation_audit_map (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    audit_key TEXT NOT NULL UNIQUE,
    audit_value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_audit_map (audit_key, audit_value)
VALUES
    ('audit_events', '{"enabled":true}'),
    ('audit_node_changes', '{"enabled":true}'),
    ('audit_trust_changes', '{"enabled":true}')
ON CONFLICT DO NOTHING;
