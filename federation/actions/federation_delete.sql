-- federation_delete.sql
-- Action: Löschen eines föderierten Knotens aus dem Netzwerk

CREATE OR REPLACE FUNCTION federation_delete(
    p_federation_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- prüfen, ob Eintrag existiert
    SELECT EXISTS(
        SELECT 1
        FROM federation
        WHERE federation_id = p_federation_id
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN FALSE;
    END IF;

    -- löschen
    DELETE FROM federation
    WHERE federation_id = p_federation_id;

    RETURN TRUE;
END;
$$;
