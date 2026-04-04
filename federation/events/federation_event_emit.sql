-- federation_event_emit.sql
-- F18: Emit eines Federation-Events (generic event emitter)

CREATE TABLE IF NOT EXISTS federation_event (
    event_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type    TEXT NOT NULL,
    federation_id UUID NOT NULL,
    payload       JSONB NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION federation_event_emit(
    p_event_type    TEXT,
    p_federation_id UUID,
    p_payload       JSONB
)
RETURNS JSONB
LANGUAGE sql
AS $$
    INSERT INTO federation_event (event_type, federation_id, payload)
    VALUES (p_event_type, p_federation_id, p_payload)
    RETURNING row_to_json(federation_event)::jsonb;
$$;
