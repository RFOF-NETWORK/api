-- F66: Event Matrix (Event-Typen x Stunden)

CREATE OR REPLACE VIEW federation_event_matrix AS
SELECT
    date_trunc('hour', created_at) AS hour,
    event_type,
    COUNT(*) AS count
FROM federation_event
GROUP BY hour, event_type
ORDER BY hour DESC;
