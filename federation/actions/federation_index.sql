-- federation_index.sql
-- Action: Liefert einen sortierten, filterbaren Index aller föderierten Knoten
-- Unterstützt: Sortierung, Filter nach Node-Type, Domain, Trust-Level

CREATE OR REPLACE FUNCTION federation_index(
    p_node_type   TEXT    DEFAULT NULL,
    p_domain      TEXT    DEFAULT NULL,
    p_min_trust   INTEGER DEFAULT NULL,
    p_max_trust   INTEGER DEFAULT NULL,
    p_limit       INTEGER DEFAULT 100,
    p_offset      INTEGER DEFAULT 0
)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT jsonb_agg(row_to_json(f))
    FROM (
        SELECT *
        FROM federation
        WHERE (p_node_type IS NULL OR node_type = p_node_type)
          AND (p_domain    IS NULL OR domain = p_domain)
          AND (p_min_trust IS NULL OR trust_level >= p_min_trust)
          AND (p_max_trust IS NULL OR trust_level <= p_max_trust)
        ORDER BY created_at DESC
        LIMIT p_limit OFFSET p_offset
    ) f;
$$;
