-- post_entry.sql
-- Modul: ledger
-- Aktion: post_entry
-- Beschreibung:
--   Diese Aktion erzeugt deterministisch einen Ledger-Eintrag und
--   aktualisiert den zugehörigen Account-Saldo.
--   Die Aktion ist transaktional, auditierbar und unveränderlich.
--   Es gibt keine Updates an Ledger-Einträgen; nur Inserts.

CREATE OR REPLACE FUNCTION post_entry(
    in_account_id uuid,
    in_direction text,          -- 'debit' oder 'credit'
    in_amount numeric(30,10),
    in_reference_id uuid DEFAULT NULL,
    in_reference_type text DEFAULT NULL,
    in_description text DEFAULT NULL,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_entry_id uuid;
    v_current_balance numeric(30,10);
    v_new_balance numeric(30,10);
BEGIN
    ------------------------------------------------------------
    -- Validierung: Richtung
    ------------------------------------------------------------
    IF in_direction NOT IN ('debit', 'credit') THEN
        RAISE EXCEPTION 'invalid_direction';
    END IF;

    ------------------------------------------------------------
    -- Validierung: Betrag
    ------------------------------------------------------------
    IF in_amount IS NULL OR in_amount <= 0 THEN
        RAISE EXCEPTION 'invalid_amount';
    END IF;

    ------------------------------------------------------------
    -- Aktuellen Saldo laden
    ------------------------------------------------------------
    SELECT balance INTO v_current_balance
    FROM account_balances
    WHERE account_id = in_account_id;

    IF v_current_balance IS NULL THEN
        RAISE EXCEPTION 'balance_not_found';
    END IF;

    ------------------------------------------------------------
    -- Neuen Saldo berechnen
    ------------------------------------------------------------
    IF in_direction = 'debit' THEN
        v_new_balance := v_current_balance - in_amount;
    ELSE
        v_new_balance := v_current_balance + in_amount;
    END IF;

    ------------------------------------------------------------
    -- Ledger-Eintrag erzeugen
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
        in_account_id,
        in_direction,
        in_amount,
        in_reference_id,
        in_reference_type,
        in_description,
        in_metadata
    )
    RETURNING id INTO v_entry_id;

    ------------------------------------------------------------
    -- Saldo aktualisieren
    ------------------------------------------------------------
    UPDATE account_balances
    SET balance = v_new_balance
    WHERE account_id = in_account_id;

    ------------------------------------------------------------
    -- Ledger-Eintrags-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_entry_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION post_entry(uuid, text, numeric, uuid, text, text, jsonb) IS
'Erzeugt deterministisch einen Ledger-Eintrag und aktualisiert den Account-Saldo.';
