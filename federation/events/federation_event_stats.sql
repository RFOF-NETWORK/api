-- F61: Event Stats (Aggregierte Statistiken)

CREATE OR REPLACE VIEW federation_event_stats AS
SELECT
    event_type,
    COUNT(*) AS total_count,
    AVG(EXTRACT(EPOCH FROM (now() - created_at))) AS avg_age_seconds
FROM federation_event
GROUP BY event_type;
