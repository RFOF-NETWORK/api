-- start_batch.sql
-- Modul: settlement
-- Aktion: start_batch
-- Beschreibung:
--   Diese Aktion eröffnet deterministisch einen neuen Settlement-Batch.
--   Es kann immer nur genau ein offener Batch existieren.
--   Die Aktion ist auditierbar, stabil und erzeugt keinerlei
--   Nebenwirkungen außerhalb der definierten Ressourcen.

CREATE OR REPLACE FUNCTION settlement_start_batch(
    in_batch_type text DEFAULT 'intraday',
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_existing_open_batch uuid;
    v_batch_id uuid;
BEGIN
    ------------------------------------------------------------
    -- Prüfen, ob bereits ein offener Settlement-Batch existiert
    ------------------------------------------------------------
    SELECT id
    INTO v_existing_open_batch
    FROM settlement_batches
    WHERE status = 'open'
    LIMIT 1;

    IF v_existing_open_batch IS NOT NULL THEN
        RAISE EXCEPTION 'open_settlement_batch_exists';
    END IF;

    ------------------------------------------------------------
    -- Batch-Typ validieren
    ------------------------------------------------------------
    IF in_batch_type NOT IN ('intraday', 'end_of_day', 'manual', 'system') THEN
        RAISE EXCEPTION 'invalid_settlement_batch_type';
    END IF;

    ------------------------------------------------------------
    -- Neuen Settlement-Batch erzeugen
    ------------------------------------------------------------
    INSERT INTO settlement_batches (
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

COMMENT ON FUNCTION settlement_start_batch(text, jsonb) IS
'Eröffnet deterministisch einen neuen Settlement-Batch. Es kann nur einen offenen Settlement-Batch geben.';
