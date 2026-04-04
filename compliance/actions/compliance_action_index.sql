CREATE INDEX IF NOT EXISTS idx_compliance_action_id
    ON compliance_actions(action_id);

CREATE INDEX IF NOT EXISTS idx_compliance_action_status
    ON compliance_actions(status);

CREATE INDEX IF NOT EXISTS idx_compliance_action_assignee
    ON compliance_actions(assignee);

CREATE INDEX IF NOT EXISTS idx_compliance_action_payload
    USING gin (payload jsonb_path_ops);
