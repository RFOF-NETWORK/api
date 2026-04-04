-- federation_heatmap.sql
-- Action: Erzeugt eine Heatmap der Trust-Level-Verteilung
-- Ausgabe: JSONB-Objekt { trust_level: count }

CREATE OR REPLACE FUNCTION federation_heatmap()
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT jsonb_object_agg(trust_level::text, count)
    FROM (
        SELECT trust_level, COUNT(*) AS count
        FROM federation
        GROUP BY trust_level
        ORDER BY trust_level
    ) t;
$$;
