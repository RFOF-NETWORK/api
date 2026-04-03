-- add_item.sql
-- Modul: settlement
-- Aktion: add_item
-- Beschreibung:
--   Diese Aktion fügt deterministisch ein Settlement-Item in den aktuell
--   offenen Settlement-Batch ein. Es kann nur einen offenen Batch geben.
--   Jedes Clearing-Result darf nur einmal verarbeitet werden.
--   Die Aktion ist auditierbar, stabil und unveränderlich.

CREATE OR REPLACE FUNCTION settlement_add_item(
    in_clearing_result_id uuid,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_batch_id uuid;
    v_result RECORD;
    v_item_id uuid;
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
    -- Clearing-Result laden
    ------------------------------------------------------------
    SELECT *
    INTO v_result
    FROM clearing_results
    WHERE id = in_clearing_result_id;

    IF v_result.id IS NULL THEN
        RAISE EXCEPTION 'clearing_result_not_found';
    END IF;

    ------------------------------------------------------------
    -- Prüfen, ob Clearing-Result bereits verarbeitet wurde
    ------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM settlement_items
        WHERE clearing_result_id = in_clearing_result_id
    ) THEN
        RAISE EXCEPTION 'result_already_settled';
    END IF;

    ------------------------------------------------------------
    -- Settlement-Item erzeugen
    ------------------------------------------------------------
    INSERT INTO settlement_items (
        batch_id,
        clearing_result_id,
        account_id,
        total_debit,
        total_credit,
        net_amount,
        currency,
        metadata
    )
    VALUES (
        v_batch_id,
        v_result.id,
        v_result.account_id,
        v_result.total_debit,
        v_result.total_credit,
        v_result.net_amount,
        v_result.currency,
        in_metadata
    )
    RETURNING id INTO v_item_id;

    ------------------------------------------------------------
    -- Batch-Statistik aktualisieren
    ------------------------------------------------------------
    UPDATE settlement_batches
    SET
        account_count = account_count + 1,
        total_net_amount = total_net_amount + v_result.net_amount
    WHERE id = v_batch_id;

    ------------------------------------------------------------
    -- Item-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_item_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION settlement_add_item(uuid, jsonb) IS
'Fügt deterministisch ein Settlement-Item in den offenen Settlement-Batch ein und aktualisiert Batch-Statistiken.';
