-- F79: Schema – Federation Labels (Tags)

CREATE TABLE IF NOT EXISTS federation_label (
    label_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    label_key TEXT NOT NULL UNIQUE,
    label_value TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
