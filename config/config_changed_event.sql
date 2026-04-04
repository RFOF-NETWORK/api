-- Event: Config geändert
CREATE TABLE IF NOT EXISTS config_changed_event (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_at TIMESTAMPTZ DEFAULT now()
);
