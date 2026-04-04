-- federation_stats.sql
-- Action: Statistische Übersicht über föderierte Knoten

CREATE OR REPLACE FUNCTION federation_stats()
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT jsonb_build_object(
        'total_nodes',      (SELECT COUNT(*) FROM federation),
        'avg_trust_level',  (SELECT AVG(trust_level) FROM federation),
        'min_trust_level',  (SELECT MIN(trust_level) FROM federation),
        'max_trust_level',  (SELECT MAX(trust_level) FROM federation),
        'by_node_type',     (
            SELECT jsonb_object_agg(node_type, count)
            FROM (
                SELECT node_type, COUNT(*) AS count
                FROM federation
                GROUP BY node_type
            ) t
        ),
        'by_domain',        (
            SELECT jsonb_object_agg(domain, count)
            FROM (
                SELECT domain, COUNT(*) AS count
                FROM federation
                GROUP BY domain
            ) d
        )
    );
$$;
