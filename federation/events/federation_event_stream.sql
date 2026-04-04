-- F53: Event Stream (continuous event feed)

CREATE OR REPLACE VIEW federation_event_stream AS
SELECT
    event_id,
    event_type,
    federation_id,
    payload,
    created_at
FROM federation_event
ORDER BY created_at DESC;
