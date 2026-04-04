-- F67: Trust Matrix (Event-Typen x Trust-Level)

CREATE OR REPLACE VIEW federation_event_trust_matrix AS
SELECT
    e.event_type,
    n.trust_level,
    COUNT(*) AS event_count
FROM federation_event e
JOIN federation_node n ON n.federation_id = e.federation_id
GROUP BY e.event_type, n.trust_level
ORDER BY event_count DESC;
