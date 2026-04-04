-- F91: Schema – Federation Relations (FK-Beziehungen)

CREATE TABLE IF NOT EXISTS federation_relation (
    relation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_table TEXT NOT NULL,
    source_column TEXT NOT NULL,
    target_table TEXT NOT NULL,
    target_column TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
