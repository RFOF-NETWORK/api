CREATE MATERIALIZED VIEW IF NOT EXISTS mv_compliance_event_stats AS
SELECT
    event_type,
    date_trunc('day', created_at) AS day,
    COUNT(*) AS count
FROM document_events
WHERE event_type LIKE 'COMPLIANCE_%'
GROUP BY event_type, date_trunc('day', created_at);

CREATE INDEX IF NOT EXISTS idx_mv_compliance_event_stats
    ON mv_compliance_event_stats(event_type, day);
