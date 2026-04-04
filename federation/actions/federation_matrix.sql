-- federation_matrix.sql
-- Action: Liefert eine kompakte 2D-Matrix aller Trust-Level zwischen allen Knoten
-- Ausgabe: JSONB-Objekt:
-- {
--   "nodes": [node_id1, node_id2, ...],
--   "matrix": [
--       [0, 80, 50],
--       [80, 0, 60],
--       [50, 60, 0]
--   ]
-- }

CREATE OR REPLACE FUNCTION federation_matrix()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_nodes   JSONB;
    v_matrix  JSONB := '[]'::jsonb;
    v_row     JSONB;
    v_node    RECORD;
    v_other   RECORD;
BEGIN
    -- Liste aller Node-IDs
    SELECT jsonb_agg(node_id::text ORDER BY node_id)
    INTO v_nodes
    FROM federation;

    -- Matrix generieren
    FOR v_node IN SELECT node_id FROM federation ORDER BY node_id LOOP
        v_row := '[]'::jsonb;

        FOR v_other IN SELECT node_id, trust_level FROM federation ORDER BY node_id LOOP
            v_row := v_row || to_jsonb(v_other.trust_level);
        END LOOP;

        v_matrix := v_matrix || jsonb_build_array(v_row);
    END LOOP;

    RETURN jsonb_build_object(
        'nodes',  v_nodes,
        'matrix', v_matrix
    );
END;
$$;
