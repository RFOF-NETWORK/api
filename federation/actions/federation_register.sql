-- federation_register.sql
-- Action: Registrierung eines föderierten Knotens im Netzwerk

CREATE OR REPLACE FUNCTION federation_register(
    p_node_id      UUID,
    p_node_type    TEXT,
    p_domain       TEXT,
    p_trust_level  INTEGER,
    p_metadata     JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_federation_id UUID;
BEGIN
    INSERT INTO federation (
        node_id,
        node_type,
        domain,
        trust_level,
        metadata
    )
    VALUES (
        p_node_id,
        p_node_type,
        p_domain,
        p_trust_level,
        p_metadata
    )
    RETURNING federation_id INTO v_federation_id;

    RETURN v_federation_id;
END;
$$;
