-- F50: Event Metrics (Count, Rate, etc.)

CREATE OR REPLACE VIEW federation_event_metrics AS
SELECT
    event_type,
    COUNT(*) AS total_events,
    MIN(created_at) AS first_event,
    MAX(created_at) AS last_event
FROM federation_event
GROUP BY event_type;
