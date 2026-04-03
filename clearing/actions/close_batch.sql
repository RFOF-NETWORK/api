-- close_batch.sql
-- Modul: clearing
-- Aktion: close_batch
-- Beschreibung:
--   Diese Aktion schließt deterministisch den aktuell offenen Clearing-Batch.
--   Sie aggregiert alle Clearing-Items pro Account, erzeugt Clearing-Results
--   und finalisiert den Batch. Nach Schließung ist der Batch unveränderlich.

CREATE OR REPLACE FUNCTION close_batch(
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_batch_id uuid;
    v_account RECORD;
    v_result_id uuid;
BEGIN
    ------------------------------------------------------------
    -- Offenen Batch laden
    ------------------------------------------------------------
    SELECT id
    INTO v_batch_id
    FROM clearing_batches
    WHERE status = 'open'
    LIMIT 1;

    IF v_batch_id IS NULL THEN
        RAISE EXCEPTION 'no_open_batch';
    END IF;

    ------------------------------------------------------------
    -- Aggregation pro Account durchführen
    ------------------------------------------------------------
    FOR v_account IN
        SELECT
            account_id,
            SUM(CASE WHEN direction = 'debit' THEN amount ELSE 0 END) AS total_debit,
            SUM(CASE WHEN direction = 'credit' THEN amount ELSE 0 END) AS total_credit,
            currency
        FROM clearing_items
        WHERE batch_id = v_batch_id
        GROUP BY account_id, currency
    LOOP
        ------------------------------------------------------------
        -- Clearing-Result erzeugen
        ------------------------------------------------------------
        INSERT INTO clearing_results (
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
            v_account.total_credit - v_account.total_debit,
            v_account.currency,
            in_metadata
        )
        RETURNING id INTO v_result_id;
    END LOOP;

    ------------------------------------------------------------
    -- Batch schließen
    ------------------------------------------------------------
    UPDATE clearing_batches
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

COMMENT ON FUNCTION close_batch(jsonb) IS
'Schließt deterministisch den offenen Clearing-Batch, erzeugt Clearing-Results und finalisiert den Batch.';
