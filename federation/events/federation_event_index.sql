-- F62: Event Index (Index-View für schnelle Suche)

CREATE OR REPLACE VIEW federation_event_index AS
SELECT
    event_id,
    event_type,
    federation_id,
    created_at
FROM federation_event
ORDER BY created_at DESC;
