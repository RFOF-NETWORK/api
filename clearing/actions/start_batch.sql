-- start_batch.sql
-- Modul: clearing
-- Aktion: start_batch
-- Beschreibung:
--   Diese Aktion eröffnet deterministisch einen neuen Clearing-Batch.
--   Es kann immer nur genau ein offener Batch existieren.
--   Die Aktion ist auditierbar, stabil und erzeugt keinerlei
--   Nebenwirkungen außerhalb der definierten Ressourcen.

CREATE OR REPLACE FUNCTION start_batch(
    in_batch_type text DEFAULT 'intraday',
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_existing_open_batch uuid;
    v_batch_id uuid;
BEGIN
    ------------------------------------------------------------
    -- Prüfen, ob bereits ein offener Batch existiert
    ------------------------------------------------------------
    SELECT id
    INTO v_existing_open_batch
    FROM clearing_batches
    WHERE status = 'open'
    LIMIT 1;

    IF v_existing_open_batch IS NOT NULL THEN
        RAISE EXCEPTION 'open_batch_exists';
    END IF;

    ------------------------------------------------------------
    -- Batch-Typ validieren
    ------------------------------------------------------------
    IF in_batch_type NOT IN ('intraday', 'end_of_day', 'manual', 'system') THEN
        RAISE EXCEPTION 'invalid_batch_type';
    END IF;

    ------------------------------------------------------------
    -- Neuen Batch erzeugen
    ------------------------------------------------------------
    INSERT INTO clearing_batches (
        batch_type,
        status,
        metadata
    )
    VALUES (
        in_batch_type,
        'open',
        in_metadata
    )
    RETURNING id INTO v_batch_id;

    ------------------------------------------------------------
    -- Batch-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_batch_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION start_batch(text, jsonb) IS
'Eröffnet deterministisch einen neuen Clearing-Batch. Es kann nur einen offenen Batch geben.';
