-- Core: Compliance Evaluate
SELECT
    c.compliance_id,
    c.compliance_type,
    c.payload,
    CASE
        WHEN (c.payload->>'risk')::int > 70 THEN 'HIGH'
        WHEN (c.payload->>'risk')::int > 40 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS evaluation
FROM compliance c
WHERE c.compliance_id = $1;
