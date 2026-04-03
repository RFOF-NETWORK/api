-- add_item.sql
-- Modul: clearing
-- Aktion: add_item
-- Beschreibung:
--   Diese Aktion fügt deterministisch ein Clearing-Item in den aktuell
--   offenen Clearing-Batch ein. Es kann nur einen offenen Batch geben.
--   Ledger-Einträge dürfen nur einmal verarbeitet werden.
--   Die Aktion ist auditierbar, stabil und unveränderlich.

CREATE OR REPLACE FUNCTION add_item(
    in_ledger_entry_id uuid,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_batch_id uuid;
    v_entry RECORD;
    v_item_id uuid;
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
    -- Ledger-Eintrag laden
    ------------------------------------------------------------
    SELECT *
    INTO v_entry
    FROM ledger_entries
    WHERE id = in_ledger_entry_id;

    IF v_entry.id IS NULL THEN
        RAISE EXCEPTION 'ledger_entry_not_found';
    END IF;

    ------------------------------------------------------------
    -- Prüfen, ob Ledger-Eintrag bereits verarbeitet wurde
    ------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM clearing_items
        WHERE ledger_entry_id = in_ledger_entry_id
    ) THEN
        RAISE EXCEPTION 'entry_already_cleared';
    END IF;

    ------------------------------------------------------------
    -- Clearing-Item erzeugen
    ------------------------------------------------------------
    INSERT INTO clearing_items (
        batch_id,
        ledger_entry_id,
        account_id,
        direction,
        amount,
        currency,
        metadata
    )
    VALUES (
        v_batch_id,
        v_entry.id,
        v_entry.account_id,
        v_entry.direction,
        v_entry.amount,
        v_entry.currency,
        in_metadata
    )
    RETURNING id INTO v_item_id;

    ------------------------------------------------------------
    -- Batch-Statistik aktualisieren
    ------------------------------------------------------------
    UPDATE clearing_batches
    SET
        entry_count = entry_count + 1,
        total_amount = total_amount + v_entry.amount
    WHERE id = v_batch_id;

    ------------------------------------------------------------
    -- Item-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_item_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION add_item(uuid, jsonb) IS
'Fügt deterministisch ein Clearing-Item in den offenen Batch ein und aktualisiert Batch-Statistiken.';
