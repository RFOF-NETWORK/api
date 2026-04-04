-- F27: Statische Federation Error Codes

CREATE TABLE IF NOT EXISTS federation_error_code (
    error_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    error_code TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO federation_error_code (error_code, description)
VALUES
    ('FED-001', 'Invalid federation node'),
    ('FED-002', 'Subscription limit exceeded'),
    ('FED-003', 'Trust level too low'),
    ('FED-004', 'Domain not allowed'),
    ('FED-005', 'Event payload invalid')
ON CONFLICT DO NOTHING;
