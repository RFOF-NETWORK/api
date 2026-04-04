-- Environment-Variablen Tabelle
CREATE TABLE IF NOT EXISTS config_env (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now()
);
