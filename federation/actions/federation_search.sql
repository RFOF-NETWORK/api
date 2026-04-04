-- federation_search.sql
-- Action: Volltextsuche über föderierte Knoten (Domain, Node-Type, Metadata)

CREATE OR REPLACE FUNCTION federation_search(
    p_query TEXT
)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT jsonb_agg(row_to_json(f))
    FROM (
        SELECT *
        FROM federation
        WHERE
            to_tsvector('simple',
                coalesce(node_type, '') || ' ' ||
                coalesce(domain, '')    || ' ' ||
                coalesce(metadata::text, '')
            )
            @@ plainto_tsquery('simple', p_query)
        ORDER BY created_at DESC
    ) f;
$$;
