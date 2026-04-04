-- federation_trust_matrix.sql
-- Action: Erzeugt eine Trust-Matrix aller föderierten Knoten
-- Ausgabe: JSONB-Objekt { node_id: { other_node_id: trust_level } }

CREATE OR REPLACE FUNCTION federation_trust_matrix()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB := '{}'::jsonb;
    v_node RECORD;
    v_other RECORD;
BEGIN
    -- alle Knoten iterieren
    FOR v_node IN SELECT federation_id, node_id FROM federation LOOP

        -- Unterobjekt für diesen Knoten erzeugen
        v_result := v_result || jsonb_build_object(
            v_node.node_id::text,
            '{}'::jsonb
        );

        -- alle anderen Knoten iterieren
        FOR v_other IN SELECT federation_id, node_id, trust_level FROM federation LOOP

            -- Trust-Level eintragen
            v_result := jsonb_set(
                v_result,
                ARRAY[v_node.node_id::text, v_other.node_id::text],
                to_jsonb(v_other.trust_level)
            );
        END LOOP;

    END LOOP;

    RETURN v_result;
END;
$$;
