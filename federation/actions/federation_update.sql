-- federation_update.sql
-- Action: Aktualisierung eines föderierten Knotens im Netzwerk

CREATE OR REPLACE FUNCTION federation_update(
    p_federation_id UUID,
    p_node_type     TEXT DEFAULT NULL,
    p_domain        TEXT DEFAULT NULL,
    p_trust_level   INTEGER DEFAULT NULL,
    p_metadata      JSONB DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_current federation%ROWTYPE;
BEGIN
    -- aktuellen Datensatz laden
    SELECT * INTO v_current
    FROM federation
    WHERE federation_id = p_federation_id;

    -- wenn nicht vorhanden → Fehler
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Federation entry % not found', p_federation_id;
    END IF;

    -- Update durchführen
    UPDATE federation
    SET
        node_type   = COALESCE(p_node_type, v_current.node_type),
        domain      = COALESCE(p_domain, v_current.domain),
        trust_level = COALESCE(p_trust_level, v_current.trust_level),
        metadata    = COALESCE(p_metadata, v_current.metadata),
        updated_at  = now()
    WHERE federation_id = p_federation_id;

    -- aktualisierten Datensatz zurückgeben
    RETURN (
        SELECT row_to_json(f)
        FROM federation f
        WHERE f.federation_id = p_federation_id
    );
END;
$$;
