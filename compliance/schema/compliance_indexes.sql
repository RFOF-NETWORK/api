-- compliance
CREATE INDEX IF NOT EXISTS idx_compliance_entity
    ON compliance(entity_id, entity_type);

CREATE INDEX IF NOT EXISTS idx_compliance_type_status
    ON compliance(compliance_type, compliance_status);

CREATE INDEX IF NOT EXISTS idx_compliance_payload_gin
    ON compliance USING gin (payload jsonb_path_ops);

-- compliance_actions
CREATE INDEX IF NOT EXISTS idx_compliance_actions_compliance_id
    ON compliance_actions(compliance_id);

CREATE INDEX IF NOT EXISTS idx_compliance_actions_status
    ON compliance_actions(status);

CREATE INDEX IF NOT EXISTS idx_compliance_actions_assignee
    ON compliance_actions(assignee);

CREATE INDEX IF NOT EXISTS idx_compliance_actions_payload_gin
    ON compliance_actions USING gin (payload jsonb_path_ops);

-- document_events
CREATE INDEX IF NOT EXISTS idx_document_events_type_created_at
    ON document_events(event_type, created_at);

CREATE INDEX IF NOT EXISTS idx_document_events_entity
    ON document_events(entity_id, entity_type);

CREATE INDEX IF NOT EXISTS idx_document_events_payload_gin
    ON document_events USING gin (payload jsonb_path_ops);

-- logs
CREATE INDEX IF NOT EXISTS idx_route_log_event_id
    ON document_event_route_log(event_id);

CREATE INDEX IF NOT EXISTS idx_dispatch_log_event_id
    ON document_event_dispatch_log(event_id);

CREATE INDEX IF NOT EXISTS idx_bus_log_event_id
    ON document_event_bus_log(event_id);

CREATE INDEX IF NOT EXISTS idx_stream_log_event_id
    ON document_event_stream_log(event_id);

CREATE INDEX IF NOT EXISTS idx_retry_log_event_id
    ON document_event_retry_log(event_id);

CREATE INDEX IF NOT EXISTS idx_deadletter_log_event_id
    ON document_event_deadletter_log(event_id);
