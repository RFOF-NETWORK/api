-- federation_history.sql
-- Action: Liefert die vollständige Änderungs- und Ereignishistorie
-- eines föderierten Knotens (federation_id)

-- 1) History-Tabelle (falls nicht vorhanden)
CREATE TABLE IF NOT EXISTS federation_history (
    history_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    federation_id    UUID NOT NULL,
    event_type       TEXT NOT NULL,          -- REGISTER, UPDATE, DELETE, TRUST_CHANGE, DOMAIN_CHANGE, etc.
    old_value        JSONB,
    new_value        JSONB,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2) Funktion: History abrufen
CREATE OR REPLACE FUNCTION federation_history(
    p_federation_id UUID
)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT jsonb_agg(row_to_json(h))
    FROM (
        SELECT *
        FROM federation_history
        WHERE federation_id = p_federation_id
        ORDER BY created_at ASC
    ) h;
$$;
