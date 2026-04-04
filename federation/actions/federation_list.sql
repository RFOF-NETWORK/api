-- federation_list.sql
-- Action: Liste aller föderierten Knoten im Netzwerk

CREATE OR REPLACE FUNCTION federation_list(
    p_limit  INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT jsonb_agg(row_to_json(f))
    FROM (
        SELECT *
        FROM federation
        ORDER BY created_at DESC
        LIMIT p_limit OFFSET p_offset
    ) f;
$$;
