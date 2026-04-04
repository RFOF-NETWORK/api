-- federation_kpi.sql
-- Action: Liefert Key Performance Indicators (KPIs) für das Föderationsnetzwerk

CREATE OR REPLACE FUNCTION federation_kpi()
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT jsonb_build_object(
        'total_nodes',          (SELECT COUNT(*) FROM federation),
        'unique_domains',       (SELECT COUNT(DISTINCT domain) FROM federation),
        'unique_node_types',    (SELECT COUNT(DISTINCT node_type) FROM federation),
        'avg_trust_level',      (SELECT AVG(trust_level) FROM federation),
        'median_trust_level',   (
            SELECT PERCENTILE_CONT(0.5)
                   WITHIN GROUP (ORDER BY trust_level)
            FROM federation
        ),
        'nodes_trust_90_plus',  (
            SELECT COUNT(*)
            FROM federation
            WHERE trust_level >= 90
        ),
        'nodes_trust_below_50', (
            SELECT COUNT(*)
            FROM federation
            WHERE trust_level < 50
        ),
        'most_common_domain',   (
            SELECT domain
            FROM federation
            GROUP BY domain
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ),
        'most_common_node_type',(
            SELECT node_type
            FROM federation
            GROUP BY node_type
            ORDER BY COUNT(*) DESC
            LIMIT 1
        )
    );
$$;
