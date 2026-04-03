-- post_transfer.sql
-- Modul: ledger
-- Aktion: post_transfer
-- Beschreibung:
--   Diese Aktion führt eine deterministische, atomare Übertragung zwischen
--   zwei Accounts durch. Sie erzeugt zwei Ledger-Einträge:
--     1. Debit beim Quellkonto
--     2. Credit beim Zielkonto
--   Beide Salden werden aktualisiert.
--   Die Aktion ist vollständig transaktional und auditierbar.

CREATE OR REPLACE FUNCTION post_transfer(
    in_source_account_id uuid,
    in_target_account_id uuid,
    in_amount numeric(30,10),
    in_reference_id uuid DEFAULT NULL,
    in_reference_type text DEFAULT NULL,
    in_description text DEFAULT NULL,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS jsonb AS $$
DECLARE
    v_source_balance numeric(30,10);
    v_target_balance numeric(30,10);
    v_new_source_balance numeric(30,10);
    v_new_target_balance numeric(30,10);

    v_debit_entry_id uuid;
    v_credit_entry_id uuid;
BEGIN
    ------------------------------------------------------------
    -- Validierung: Betrag
    ------------------------------------------------------------
    IF in_amount IS NULL OR in_amount <= 0 THEN
        RAISE EXCEPTION 'invalid_amount';
    END IF;

    ------------------------------------------------------------
    -- Salden laden
    ------------------------------------------------------------
    SELECT balance INTO v_source_balance
    FROM account_balances
    WHERE account_id = in_source_account_id;

    IF v_source_balance IS NULL THEN
        RAISE EXCEPTION 'source_balance_not_found';
    END IF;

    SELECT balance INTO v_target_balance
    FROM account_balances
    WHERE account_id = in_target_account_id;

    IF v_target_balance IS NULL THEN
        RAISE EXCEPTION 'target_balance_not_found';
    END IF;

    ------------------------------------------------------------
    -- Neue Salden berechnen
    ------------------------------------------------------------
    v_new_source_balance := v_source_balance - in_amount;
    v_new_target_balance := v_target_balance + in_amount;

    ------------------------------------------------------------
    -- Ledger-Eintrag: Debit (Quelle)
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
        in_source_account_id,
        'debit',
        in_amount,
        in_reference_id,
        in_reference_type,
        in_description,
        in_metadata
    )
    RETURNING id INTO v_debit_entry_id;

    ------------------------------------------------------------
    -- Ledger-Eintrag: Credit (Ziel)
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
        in_target_account_id,
        'credit',
        in_amount,
        in_reference_id,
        in_reference_type,
        in_description,
        in_metadata
    )
    RETURNING id INTO v_credit_entry_id;

    ------------------------------------------------------------
    -- Salden aktualisieren
    ------------------------------------------------------------
    UPDATE account_balances
    SET balance = v_new_source_balance
    WHERE account_id = in_source_account_id;

    UPDATE account_balances
    SET balance = v_new_target_balance
    WHERE account_id = in_target_account_id;

    ------------------------------------------------------------
    -- Ergebnis zurückgeben
    ------------------------------------------------------------
    RETURN jsonb_build_object(
        'debit_entry_id', v_debit_entry_id,
        'credit_entry_id', v_credit_entry_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION post_transfer(uuid, uuid, numeric, uuid, text, text, jsonb) IS
'Führt eine deterministische, atomare Übertragung zwischen zwei Accounts durch.';
