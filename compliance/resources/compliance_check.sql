-- Core: Compliance Check
SELECT
    c.compliance_id,
    c.compliance_status,
    c.payload
FROM compliance c
WHERE c.compliance_id = $1;
