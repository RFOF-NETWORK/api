-- F65: Event KPI (Key Performance Indicators)

CREATE OR REPLACE VIEW federation_event_kpi AS
SELECT
    event_type,
    COUNT(*) AS total_events,
    COUNT(*) FILTER (WHERE created_at > now() - INTERVAL '1 hour') AS last_hour,
    COUNT(*) FILTER (WHERE created_at > now() - INTERVAL '1 day') AS last_day
FROM federation_event
GROUP BY event_type;
