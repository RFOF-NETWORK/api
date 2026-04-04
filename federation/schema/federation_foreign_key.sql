-- F92: Schema – Federation Foreign Keys (FK-Definitionen)

CREATE TABLE IF NOT EXISTS federation_foreign_key (
    fk_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fk_name TEXT NOT NULL UNIQUE,
    table_name TEXT NOT NULL,
    column_name TEXT NOT NULL,
    ref_table TEXT NOT NULL,
    ref_column TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
