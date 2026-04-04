-- F93: Schema – Federation Indizes

CREATE TABLE IF NOT EXISTS federation_index (
    index_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    index_name TEXT NOT NULL UNIQUE,
    table_name TEXT NOT NULL,
    column_name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
