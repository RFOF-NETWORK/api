-- Core: Compliance Resolve
UPDATE compliance
SET compliance_status = 'RESOLVED',
    updated_at = now()
WHERE compliance_id = $1
RETURNING compliance_id, compliance_status, updated_at;
