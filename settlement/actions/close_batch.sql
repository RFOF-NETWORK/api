-- close_batch.sql
-- Modul: settlement
-- Aktion: close_batch
-- Beschreibung:
--   Diese Aktion schließt deterministisch den aktuell offenen Settlement-Batch.
--   Sie aggregiert alle Settlement-Items pro Account, erzeugt Settlement-Results
--   und finalisiert den Batch. Nach Schließung ist der Batch unveränderlich.

CREATE OR REPLACE FUNCTION settlement_close_batch(
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_batch_id uuid;
    v_account RECORD;
    v_result_id uuid;
BEGIN
    ------------------------------------------------------------
    -- Offenen Settlement-Batch laden
    ------------------------------------------------------------
    SELECT id
    INTO v_batch_id
    FROM settlement_batches
    WHERE status = 'open'
    LIMIT 1;

    IF v_batch_id IS NULL THEN
        RAISE EXCEPTION 'no_open_settlement_batch';
    END IF;

    ------------------------------------------------------------
    -- Aggregation pro Account durchführen
    ------------------------------------------------------------
    FOR v_account IN
        SELECT
            account_id,
            SUM(total_debit) AS total_debit,
            SUM(total_credit) AS total_credit,
            SUM(net_amount) AS net_amount,
            currency
        FROM settlement_items
        WHERE batch_id = v_batch_id
        GROUP BY account_id, currency
    LOOP
        ------------------------------------------------------------
        -- Settlement-Result erzeugen
        ------------------------------------------------------------
        INSERT INTO settlement_results (
            batch_id,
            account_id,
            total_debit,
            total_credit,
            net_amount,
            currency,
            metadata
        )
        VALUES (
            v_batch_id,
            v_account.account_id,
            v_account.total_debit,
            v_account.total_credit,
            v_account.net_amount,
            v_account.currency,
            in_metadata
        )
        RETURNING id INTO v_result_id;
    END LOOP;

    ------------------------------------------------------------
    -- Batch schließen
    ------------------------------------------------------------
    UPDATE settlement_batches
    SET
        status = 'closed',
        closed_at = now(),
        metadata = metadata || in_metadata
    WHERE id = v_batch_id;

    ------------------------------------------------------------
    -- Batch-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_batch_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION settlement_close_batch(jsonb) IS
'Schließt deterministisch den offenen Settlement-Batch, erzeugt Settlement-Results und finalisiert den Batch.';
