CREATE OR REPLACE VIEW v_compliance_open AS
SELECT *
FROM compliance
WHERE compliance_status NOT IN ('CLOSED', 'RESOLVED');

CREATE OR REPLACE VIEW v_compliance_actions_open AS
SELECT a.*, c.compliance_type, c.compliance_status
FROM compliance_actions a
JOIN compliance c ON c.compliance_id = a.compliance_id
WHERE a.status = 'OPEN';

CREATE OR REPLACE VIEW v_compliance_events_latest AS
SELECT DISTINCT ON (payload->>'compliance_id')
    event_id,
    event_type,
    entity_id,
    entity_type,
    payload,
    created_at
FROM document_events
WHERE event_type LIKE 'COMPLIANCE_%'
ORDER BY payload->>'compliance_id', created_at DESC;
