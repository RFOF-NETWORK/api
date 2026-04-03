-- reverse_entry.sql
-- Modul: ledger
-- Aktion: reverse_entry
-- Beschreibung:
--   Diese Aktion kehrt einen bestehenden Ledger-Eintrag deterministisch um.
--   Es wird ein neuer Ledger-Eintrag erzeugt, der den ursprünglichen
--   vollständig neutralisiert. Ledger-Einträge bleiben unveränderlich.
--   Die Salden werden entsprechend korrigiert.

CREATE OR REPLACE FUNCTION reverse_entry(
    in_ledger_entry_id uuid,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_entry RECORD;
    v_reverse_direction text;
    v_new_balance numeric(30,10);
    v_reverse_entry_id uuid;
BEGIN
    ------------------------------------------------------------
    -- Originaleintrag laden
    ------------------------------------------------------------
    SELECT *
    INTO v_entry
    FROM ledger_entries
    WHERE id = in_ledger_entry_id;

    IF v_entry.id IS NULL THEN
        RAISE EXCEPTION 'ledger_entry_not_found';
    END IF;

    ------------------------------------------------------------
    -- Richtung invertieren
    ------------------------------------------------------------
    IF v_entry.direction = 'debit' THEN
        v_reverse_direction := 'credit';
    ELSE
        v_reverse_direction := 'debit';
    END IF;

    ------------------------------------------------------------
    -- Saldo laden
    ------------------------------------------------------------
    SELECT balance
    INTO v_new_balance
    FROM account_balances
    WHERE account_id = v_entry.account_id;

    IF v_new_balance IS NULL THEN
        RAISE EXCEPTION 'balance_not_found';
    END IF;

    ------------------------------------------------------------
    -- Neuen Saldo berechnen
    ------------------------------------------------------------
    IF v_reverse_direction = 'credit' THEN
        v_new_balance := v_new_balance + v_entry.amount;
    ELSE
        v_new_balance := v_new_balance - v_entry.amount;
    END IF;

    ------------------------------------------------------------
    -- Gegenbuchung erzeugen
    ------------------------------------------------------------
    INSERT INTO ledger_entries (
        account_id,
        direction,
        amount,
        reference_id,
        reference_type,
        description,
        metadata
    )
    VALUES (
        v_entry.account_id,
        v_reverse_direction,
        v_entry.amount,
        v_entry.reference_id,
        v_entry.reference_type,
        'REVERSAL OF ' || v_entry.id,
        in_metadata
    )
    RETURNING id INTO v_reverse_entry_id;

    ------------------------------------------------------------
    -- Saldo aktualisieren
    ------------------------------------------------------------
    UPDATE account_balances
    SET balance = v_new_balance
    WHERE account_id = v_entry.account_id;

    ------------------------------------------------------------
    -- Reversal-Eintrags-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_reverse_entry_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION reverse_entry(uuid, jsonb) IS
'Kehrt einen Ledger-Eintrag deterministisch um und erzeugt eine Gegenbuchung.';
