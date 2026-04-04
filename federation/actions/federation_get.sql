-- federation_get.sql
-- Action: Abruf eines föderierten Knotens anhand der federation_id

CREATE OR REPLACE FUNCTION federation_get(
    p_federation_id UUID
)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT row_to_json(f)::jsonb
    FROM federation f
    WHERE f.federation_id = p_federation_id;
$$;
