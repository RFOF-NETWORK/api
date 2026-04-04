-- Core: Compliance Update
UPDATE compliance
SET payload = $2,
    updated_at = now()
WHERE compliance_id = $1
RETURNING compliance_id, payload, updated_at;
