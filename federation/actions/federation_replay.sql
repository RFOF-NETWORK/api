-- federation_replay.sql
-- Action: Rekonstruiert den Zustand eines föderierten Knotens
-- zu einem bestimmten Zeitpunkt anhand der federation_history

CREATE OR REPLACE FUNCTION federation_replay(
    p_federation_id UUID,
    p_timestamp     TIMESTAMPTZ
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_events JSONB;
    v_state  JSONB := '{}'::jsonb;
    v_event  JSONB;
    i        INTEGER;
BEGIN
    -- relevante Events laden
    SELECT jsonb_agg(row_to_json(h)::jsonb ORDER BY created_at ASC)
    INTO v_events
    FROM federation_history h
    WHERE h.federation_id = p_federation_id
      AND h.created_at <= p_timestamp;

    IF v_events IS NULL THEN
        RETURN NULL;
    END IF;

    -- Events sequenziell anwenden
    FOR i IN 0 .. jsonb_array_length(v_events) - 1 LOOP
        v_event := v_events->i;

        v_state :=
            COALESCE(v_event->'new_value', '{}'::jsonb)
            || v_state;
    END LOOP;

    RETURN v_state;
END;
$$;
