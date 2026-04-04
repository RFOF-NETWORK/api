-- F24: Federation Templates (z.B. für Auto-Provisioning)

CREATE TABLE IF NOT EXISTS federation_template (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_name TEXT NOT NULL UNIQUE,
    template_data JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_template (template_name, template_data)
VALUES
    ('minimal_node', '{"trust":70,"domain":"edge","subscriptions":[]}'),
    ('standard_node', '{"trust":80,"domain":"core","subscriptions":["core"]}')
ON CONFLICT DO NOTHING;
