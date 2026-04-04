-- FK: actions → compliance
ALTER TABLE compliance_actions
    ADD CONSTRAINT fk_compliance_actions_compliance
    FOREIGN KEY (compliance_id)
    REFERENCES compliance(compliance_id)
    ON DELETE CASCADE;

-- FK: action_history → actions
ALTER TABLE compliance_action_history
    ADD CONSTRAINT fk_action_history_action
    FOREIGN KEY (action_id)
    REFERENCES compliance_actions(action_id)
    ON DELETE CASCADE;

-- FK: logs → events
ALTER TABLE document_event_route_log
    ADD CONSTRAINT fk_route_log_event
    FOREIGN KEY (event_id)
    REFERENCES document_events(event_id)
    ON DELETE CASCADE;

ALTER TABLE document_event_dispatch_log
    ADD CONSTRAINT fk_dispatch_log_event
    FOREIGN KEY (event_id)
    REFERENCES document_events(event_id)
    ON DELETE CASCADE;

ALTER TABLE document_event_bus_log
    ADD CONSTRAINT fk_bus_log_event
    FOREIGN KEY (event_id)
    REFERENCES document_events(event_id)
    ON DELETE CASCADE;

ALTER TABLE document_event_stream_log
    ADD CONSTRAINT fk_stream_log_event
    FOREIGN KEY (event_id)
    REFERENCES document_events(event_id)
    ON DELETE CASCADE;

ALTER TABLE document_event_retry_log
    ADD CONSTRAINT fk_retry_log_event
    FOREIGN KEY (event_id)
    REFERENCES document_events(event_id)
    ON DELETE CASCADE;

ALTER TABLE document_event_deadletter_log
    ADD CONSTRAINT fk_deadletter_log_event
    FOREIGN KEY (event_id)
    REFERENCES document_events(event_id)
    ON DELETE CASCADE;
