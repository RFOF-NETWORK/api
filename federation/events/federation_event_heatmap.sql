-- F60: Event Heatmap (Events pro Stunde)

CREATE OR REPLACE VIEW federation_event_heatmap AS
SELECT
    date_trunc('hour', created_at) AS hour,
    event_type,
    COUNT(*) AS event_count
FROM federation_event
GROUP BY hour, event_type
ORDER BY hour DESC;
